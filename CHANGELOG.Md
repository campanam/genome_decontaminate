# genome_decontaminate  
Michael G. Campana, 2019-2022  
Smithsonian Conservation Biology Institute  

## CHANGELOG  
### Version 0.3.0  
Interface using OptParser and ostruct  
Duplication removal option  
Ability to split sequences at contamination sections  
Minimum sequence length option  
Fix in trimming to allow multiple spans to be trimmed for same chromosome  
Can read gzipped files using congenlib's gz_file_open  

### Version 0.2.0  
Can optionally soft mask regions with lowercase letters  

### Version 0.1.0  
Trims contaminants and hard masks regions with Ns  
