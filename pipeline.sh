## ASSEMBLY

# Merge all the ONT reads
cat 0.Raw_reads/ONT/*fastq.gz > 0.Raw_reads/ONT/input.ONT.fastq.gz

# Trimming ONT
filtlong --keep_percent 90 0.Raw_reads/ONT/input.ONT.fastq.gz | gzip > 2.Trimming/input.ONT.quality.fastq.gz
# Trimming Illumina
fastp -i 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R1_001.fastq.gz -I 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R2_001.fastq.gz -o 2.Trimming/118514_ID3069_1-SMA3_S136_L004_R1_001.TRIMMED.fastq.gz -O 2.Trimming/118514_ID3069_1-SMA3_S136_L004_R2_001.TRIMMED.fastq.gz

# Assembly FLYE
flye --nano-raw 2.Trimming/input.ONT.quality.fastq.gz --genome-size 5m --out-dir 3.0.ONT.assembly --threads 15 --iterations 5 --plasmids --asm-coverage 50

# Fixtsart with Circlator
mkdir 3.1.Circlator
circlator fixstart 3.ONT.assembly/assembly.fasta Circulator
mv Circulator* 3.1.Circlator

# Polishing with Pilon (FIRST RUN)
mkdir 4.Polishing/FIRST_RUN

mkdir 3.1.Circlator/bwa-index
cp 3.1.Circlator/Circulator.fasta 3.1.Circlator/bwa-index

bwa index 3.1.Circlator/bwa-index/Circulator.fasta
bwa mem -t 20 -a 3.1.Circlator/bwa-index/Circulator.fasta 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R1_001.fastq.gz 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R2_001.fastq.gz | samtools sort -@8 -o  4.Polishing/FIRST_RUN/mapping1.sort.bam -
samtools index 4.Polishing/FIRST_RUN/mapping1.sort.bam
java -Xmx32G -jar ~/Programs/pilon-1.24.jar --genome 3.1.Circlator/bwa-index/Circulator.fasta --frags 4.Polishing/FIRST_RUN/mapping1.sort.bam --output assembly.pilon1.fasta --outdir 4.Polishing/SECOND_RUN --changes --vcf --tracks

# Polishing with Pilon (SECOND RUN)
bwa index 4.Polishing/SECOND_RUN/assembly.pilon1.fasta.fasta
bwa mem -t 20 -a 4.Polishing/SECOND_RUN/assembly.pilon1.fasta.fasta 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R1_001.fastq.gz 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R2_001.fastq.gz | samtools sort -@8 -o 4.Polishing/SECOND_RUN/mapping2.sort.bam -
samtools index 4.Polishing/SECOND_RUN/mapping2.sort.bam
java -Xmx32G -jar ~/Programs/pilon-1.24.jar --genome 4.Polishing/SECOND_RUN/assembly.pilon1.fasta.fasta --frags 4.Polishing/SECOND_RUN/mapping2.sort.bam --output assembly.pilon2.fasta --outdir 4.Polishing/THIRD_RUN --changes --vcf --tracks

# Polishing with Pilon (THIRD RUN)
bwa index 4.Polishing/THIRD_RUN/assembly.pilon2.fasta.fasta
bwa mem -t 20 -a 4.Polishing/THIRD_RUN/assembly.pilon2.fasta.fasta 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R1_001.fastq.gz 0.Raw_reads/Illumina/118514_ID3069_1-SMA3_S136_L004_R2_001.fastq.gz | samtools sort -@8 -o 4.Polishing/THIRD_RUN/mapping3.sort.bam -
samtools index 4.Polishing/THIRD_RUN/mapping3.sort.bam
java -Xmx32G -jar ~/Programs/pilon-1.24.jar --genome 4.Polishing/THIRD_RUN/assembly.pilon2.fasta.fasta --frags 4.Polishing/THIRD_RUN/mapping3.sort.bam --output assembly.pilon3.fasta --outdir 4.Polishing/FOURTH_RUN --changes --vcf --tracks

# Copy the final assembled polished genome to the 4.Polishing folder and rename it
mv 4.Polishing/FOURTH_RUN/assembly.pilon3.fasta.fasta 4.Polishing/Final.assembly.circularized.polished.fasta

## ASSEMBLY QUALITY

# BUSCO analysis
busco -i 4.Polishing/Final.assembly.circularized.polished.fasta -m genome -l xanthomonadales_odb10 -c 20 -o 5.Stats/Final.assembly.circularized.polished.busco

# General stats
stats.sh in=4.Polishing/Final.assembly.circularized.polished.fasta out=5.Stats/Final.assembly.circularized.polished.stats

## ANNOTATION

# Genome annotation with pgap
cp 4.Polishing/Final.assembly.circularized.polished.fasta 6.Annotation/PGAP/
~/Programs/pgap-master/scripts/pgap.py -c 20 -m 12g -n -o Sindicatrix_PGAP_NCBI generic.yaml # please refer to the PGAP github for an in-depth description of what YML file is used for

# Genome viewer
genovi -i  6.Annotation/PGAP/Sindicatrix_PGAP_NCBI/annot.gbk -s complete -t Stenotrophomonas_indicatrix --title_position center
