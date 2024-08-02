# Assembly and annotation workflow (proposed as a script) employed for the Stenotrophomonas indicatrix DAI2m/c WGS 								        
The output files (assembly and annotation of the genome) can be found in the article:											
<B>"Life in Plastic: novel insights into insect-mediated polystyrene biodegradation through genome assembly and annotation of Stenotrophomonas indicatrix strain DAI2m/c" </B>
currently submitted to the journal Microbial Genomics.														


Note that script always performs the commands starting from the working folder (i.e. Analysis) and assumes a tree structure as follows:					
```
Analysis																					
	├── 0.Raw_reads																			
	│   ├── Illumina																		
	│   └── ONT																			
	├── 1.Quality																			
	├── 2.Trimming																				
	├── 3.0.ONT.assembly																			
	├── 3.1.Circlator																			
	├── 4.Polishing																			
	├── 5.Stats																				
	├── 6.Annotation																			
	    └── PGAP	
   ```			
