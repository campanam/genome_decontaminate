#!/bin/bash/ruby
# Michael G. Campana, 2019

$drop_seqs = [] # Sequences to exclude
$trim_seqs = {} # Sequences to trim

def read_contaminants(contam_file)
	File.open(contam_file, 'r') do |f1|
		exclude = false
		trim = false
		while line = f1.gets
			if exclude
				if line == "\n"
					exclude = false
				elsif line != "Sequence name, length, apparent source\n"
					$drop_seqs.push(line.split("\t")[0])
				end
			elsif trim
				if line == "\n"
					trim = false
				elsif line != "Sequence name, length, span(s), apparent source\n"
					larr = line.split("\t")
					span = larr[2].split("..")
					$trim_seqs[larr[0]] = [span[0].to_i - 1,span[1].to_i - 1]
				end
			elsif line	== "Exclude:\n"
				exclude = true
			elsif line == "Trim:\n"
				trim = true
			end
		end
	end
end
def decontaminate(input_file)
	@printline = true
	@trimline = false
	File.open(ARGV[0], 'r') do |f1|
		while line = f1.gets
			if line[0].chr == ">"
				chromo = line[1...-1].split(" ")[0] # Get chromosome name and remove tags
				$drop_seqs.include?(chromo) ? @printline = false : @printline = true				
				$trim_seqs.keys.include?(chromo) ? @trimline = true : @trimline = false
			elsif @trimline
				for i in $trim_seqs[chromo][0]..$trim_seqs[chromo][1]
					line[i] = "N"
				end
			end
			if @printline
				puts line
			end
		end
	end
end
if ARGV[0].nil?
	puts "Usage: ruby genome_decontaminate.rb <input_fasta> <NCBI_contaminant_file> > <output_fasta>"
else
	read_contaminants(ARGV[1])
	decontaminate(ARGV[0])
end

