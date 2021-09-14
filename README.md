# genome_decontaminate  

Michael G. Campana, 2019  
Smithsonian Conservation Biology Institute  

Script to remove NCBI-identified contaminant sequences from a genome  

## Requirements and Installation  
The script requires [Ruby](http://www.ruby-lang.org) >= 2.0. Download the script using:  
`git clone https://github.com/campanam/genome_decontaminate`  
Then move the `genome_decontaminate.rb` script to the desired location.  

## Input  
The script requires the genome sequence submitted to NCBI in unwrapped fasta format. It also requires the NCBI contamination screen results file in text format (typically named 'FCSreport.txt').  

## Usage  
Execute the following command substituting your file names as appropriate:  
`ruby genome_decontaminate.rb <input_fasta> <NCBI_contaminant_file> > <output_fasta>`  

## Citation  
Campana, M.G. 2019. genome_decontaminate. <https://github.com/campanam/genome_decontaminate>.  
