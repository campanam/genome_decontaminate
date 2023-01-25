# genome_decontaminate  

Michael G. Campana, 2019-2022  
Smithsonian Conservation Biology Institute  

Script to remove NCBI-identified contaminant sequences from a genome  

## License  
The software is made available under the [Smithsonian Institution terms of use](https://www.si.edu/termsofuse).  

## Requirements and Installation  
The script requires [Ruby](http://www.ruby-lang.org) >= 2.4.1 and [congenlib](https://github.com/campanam/congenlib).  

After installing Ruby and congenlib, download the script using:  
`git clone https://github.com/campanam/genome_decontaminate`  
Then move the `genome_decontaminate.rb` script to the desired location.  

## Input  
The script requires the genome sequence submitted to NCBI in unwrapped fasta format. It also requires the NCBI contamination screen results file in text format (typically named 'FCSreport.txt').  

## Usage  
Execute the following command substituting your file names as appropriate:  
`ruby genome_decontaminate.rb -g <input_fasta> -c <NCBI_contaminant_file> [options] > <output_fasta>`  

Options:  
`-g, --genome [FILE]`: Input genome FASTA file.  
`-c, --contam [FILE]`: Input NCBI contamination file.  
 `--soft`: Soft mask contaminants in lower case (Default is hard masked using Ns).  
`--duplicated`: Remove duplicated sequences.  
`--splitcontam`: Split sequences at internal contaminations. Overrides soft/hard masking.  
`--markmt`: Mark mitochondrial contigs rather than remove them.  
`-M, --minlen [VALUE]`: Minimum length in bp to retain a sequence (Default is 200).  
`-h, --help`: Show help.  


## Citation  
Campana, M.G. 2019-2022. genome_decontaminate. <https://github.com/campanam/genome_decontaminate>.  
