#!/bin/bash/ruby
#-----------------------------------------------------------------------------------------
# Michael G. Campana, 2019-2022
# Smithsonian Conservation Biology Institute
# genome_decontaminate v0.4.0
#-----------------------------------------------------------------------------------------
require 'ostruct'
require 'optparse'
require 'congenlib'

$drop_seqs = [] # Sequences to exclude
$trim_seqs = {} # Sequences to trim
$markmt_seqs = [] # Sequences to mark as mitochondrial
#-----------------------------------------------------------------------------------------
def read_contaminants
	gz_file_open($options.contam_file) do |f1|
		exclude = false
		trim = false
		duplicated = false
		while line = f1.gets
			if exclude
				if line == "\n"
					exclude = false
				elsif line != "Sequence name, length, apparent source\n"
					larr = line.strip.split("\t")
					if $options.markmt && larr[2] == 'mitochondrion'
						$markmt_seqs.push(larr[0])
					else
						$drop_seqs.push(larr[0])
					end
				end
			elsif trim
				if line == "\n"
					trim = false
				elsif line != "Sequence name, length, span(s), apparent source\n"
					larr = line.split("\t")
					spans = larr[2].split(",")
					$trim_seqs[larr[0]] = spans
				end
			elsif duplicated
				if line == "\n"
					duplicated = false
				elsif line != "Sequence names, length\n"
					unless line[0].chr == "#"
						larr = line.split[1...-2] # Exclude first entry and last two entries to keep one sequence and remove lengths
						for seq in larr
							seq.delete!("RC()")
							$drop_seqs.push(seq)
						end
					end
				end
			elsif line	== "Exclude:\n"
				exclude = true
			elsif line == "Trim:\n"
				trim = true
			elsif line == "Duplicated:\n"
				duplicated = true if $options.duplicated
			end
		end
	end
end
#-----------------------------------------------------------------------------------------
def decontaminate
	@printline = false # Switch to whether a sequence should be printed
	@trimline = false # Switch to trim a sequence
	@splitline = false # Switch designating to skip adding the line because already added during the split line section
	@mtline = false # Switch to mark sequence as mt
	outline = ""
	@mtoutline = "" # Outline for mt sequences to be placed at end of assembly
	gz_file_open($options.genome) do |f1|
		while line = f1.gets
			if line[0].chr == ">"
				if @printline # Print lines here because of possibility of dropping lines and adding new sequences
					puts outline
					outline = ""
				end
				chromo = line[1...-1].split(" ")[0] # Get chromosome name and remove tags
				$drop_seqs.include?(chromo) ? @printline = false : @printline = true				
				$trim_seqs.keys.include?(chromo) ? @trimline = true : @trimline = false
				$markmt_seqs.include?(chromo) ? @mtline = true : @mtline = false
			else
				if line.strip.length < $options.minlen
					# Remove sequence that is too short and clear the outline
					outline = ""
					@printline = false
				elsif @trimline
					if $options.splitcontam
						@splitline = true
						header = outline.split(" ")[0] + "_part"
						outline = ""
						partcount = 1
						startbase = 0
						endbase = 0
					end
					for span in $trim_seqs[chromo]
						span_arr = span.split("..").map { |x| x.to_i - 1}
						if $options.splitcontam
							endbase = span_arr[0] - 1 # Get last base before split section
							if endbase - startbase > $options.minlen # Only retain long enough segments
								outline << header + partcount.to_s + "\n" + line[startbase..endbase] + "\n"
								startbase = span_arr[1]+1
								endbase = line.strip.length - 1
								partcount += 1
							end
						else
							for i in span_arr[0]..span_arr[1]
								$options.soft ? line[i] = line[i].downcase : line[i] = "N"
							end
						end
					end
				end
			end
			if @printline
				if @splitline # Add final section if above minimum length
					@splitline = false
					if endbase - startbase > $options.minlen
						outline << header + partcount.to_s + "\n" + line[startbase..endbase] + "\n"
					end
				elsif @mtline
					if line[0].chr == '>'
						header = line.split(" ")[0] + ' [location=mitochondrion]' + "\n"
						@mtoutline << header
					else
						@mtoutline << line
					end
				else
					outline << line
				end
			end
		end
	end
	puts outline if @printline # Print last batch of lines
	puts @mtoutline # Print marked mitochondrial sequences
end
#-----------------------------------------------------------------------------------------
class Parser
	def self.parse(options)
		args = OpenStruct.new
		args.genome = "" # Input genome file
		args.contam_file = "" # NCBI Contamination file
		args.soft = false # Soft mask contaminants in lower case
		args.splitcontam = false # Split sequences at internal contaminations
		args.duplicated = false # Remove duplicated sequences
		args.markmt = false # Mark rather than exclude mitochondrial contigs
		args.minlen = 200 # Minimum length to keep a sequence
		opt_parser = OptionParser.new do |opts|
			opts.banner = "genome_decontaminate.rb version 0.4.0 by Michael G. Campana (2019-2022), Smithsonian's National Zoo & Conservation Biology Institute"
			opts.separator ""
			opts.separator "Command-line usage: ruby genome_decontaminate.rb [options] -g <genome.fsa> -c <NCBI_Contamination.txt>"
			opts.on("-g","--genome [FILE]", String, "Input genome FASTA file") do |genome|
				args.genome = genome
			end
			opts.on("-c","--contam [FILE]", String, "Input NCBI contamination file") do |contam|
				args.contam_file = contam
			end
			opts.on("--soft", "Soft mask  contaminants in lower case (Default is hard masked using Ns).") do |soft|
				args.soft = true
			end
			opts.on("--duplicated", "Remove duplicated sequences.") do |dup|
				args.duplicated = true
			end
			opts.on("--splitcontam", "Split sequences at internal contaminations. Overrides soft/hard masking.") do |splitcontam|
				args.splitcontam = true
				args.soft = false
			end
			opts.on("--markmt", "Mark mitochondrial contigs rather than remove them.") do |markmt|
				args.markmt = true
			end
			opts.on("-M", "--minlen [VALUE]", Integer, "Minimum length in bp to retain a sequence (Default is 200).") do |minlen|
				args.minlen = minlen if minlen != nil
			end
			opts.on_tail("-h","--help", "Show help") do
				puts opts
				exit
			end
		end
		opt_parser.parse!(options)
		return args
	end
end
#-----------------------------------------------------------------------------------------
ARGV[0] ||= "-h"
$options = Parser.parse(ARGV)
read_contaminants
decontaminate