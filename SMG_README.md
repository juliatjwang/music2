# music2
<b>REFERENCES FOR USE:</b><br>
https://github.com/ding-lab/MuSiC2<br>
http://gmt.genome.wustl.edu/packages/genome-music/documentation.html

<b>MuSic2 SMG walkthrough for use on the MGI server</b> / work log for using MuSiC2 to call SMGs for CPTAC3 UCEC samples

Files needed:
1. <b> Regions-of-interest (ROI) file: </b> text file with 4 tab delimited columns [chromosome start stop name_of_region]; ROIs from the same chromosome must be listed adjacent to each other in this file; overlapping ROIs of the same gene must be merged. BEDtools' mergeBed can help if used per gene.
2. <b> Bam list </b> formatted as 3 tab delimited columns [sampleID normal_bam tumor_bam]
3. <b> Reference sequence </b> 
4. <b> MAF file </b> (list of mutations using TCGA MAF specification v2.3) - if the chromosome numbers contain "chr" in the ROI file, they must also contain "chr" here. Make sure the tumor sample IDs in the MAF file match the sample IDs in the bam list!

<b>----Load docker on mgi----</b>

Load the following docker image after logging onto MGI: <b> juliatjwang/music2:fixed_withR </b>

`docker interactive juliatjwang/music2:fixed_withR`

Run the following for bsub access:

`export PATH=/opt/lsf9/9.1/linux2.6-glibc2.3-x86_64/etc:/opt/lsf9/9.1/linux2.6-glibc2.3-x86_64/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin`

<b>----Make working directory and subdirectories for log files----</b>
For example:

`mkdir music2_smg_running`<br>
`cd music2_smg_running`<br>
`mkdir logs`

<b>----Generate "calculate coverage" command list file----</b>
This will generate a text file with a list of commands to run music2 covg for every sample. Each line will have single quotes - keep these!

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo LOG_FILE_HERE music2 bmr calc-covg --roi-file ROI_FILE_HERE --reference-sequence REFERENCE_FASTA_HERE --bam-list BAM_LIST_HERE --output-dir OUTPUT_DIRECTORY_HERE --cmd-list-file OUTPUT_COMMAND_LIST_FILE_HERE`

EXAMPLE for UCEC MSI subtype:

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/logs/log_get_command_list.txt music2 bmr calc-covg --roi-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/gencode_v29_ROI.txt --reference-sequence /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/A_Reference/GRCh38.d1.vd1.fa --bam-list /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/bam_lists_by_subgroup/reformatted/UCEC_msi_bamlist.txt --output-dir /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/ --cmd-list-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/msi.run-coverage-command`

<b>----Put in bsub command in front of all lines in the command list to run in parallel----</b>
Open the generated command list file in vim, then input:

`:%s/\'music2 bmr/bsub -q research-hpc -n 1 -R \"select[mem>30000] rusage[mem=30000]\" -M 30000000 -a \'docker(juliatjwang\/music2:fixed_withR)\' -oo LOG_FILE_HERE \'music2 bmr/g`

EXAMPLE for UCEC MSI"

`:%s/\'music2 bmr/bsub -q research-hpc -n 1 -R \"select[mem>30000] rusage[mem=30000]\" -M 30000000 -a \'docker(juliatjwang\/music2:fixed_withR)\' -oo \/gscmnt\/gc2532\/dinglab\/jwang\/CPTAC3\/UCEC_SMG\/msi\/music2_smg_running\/logs\\/log_running_cov_commands1.txt \'music2 bmr/g`

<b>----Run roi coverage for each sample----</b>

`bash OUTPUT_COMMAND_LIST_FILE_HERE`

EXAMPLE for UCEC MSI:

`bash msi.run-coverage-command`

<b>----Run "bmr calc-covg" a second time to merge the parallelized calculations----</b>
NOTE: --cmd_list_file and --cmd_prefix have been removed this time

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo LOG_FILE_HERE music2 bmr calc-covg --roi-file ROI_FILE_HERE --reference-sequence REFERENCE_FASTA_HERE --bam-list BAM_LIST_HERE --output-dir OUTPUT_DIRECTORY_HERE`

EXAMPLE for UCEC MSI:

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/logs/log_get_command_list_merge.txt music2 bmr calc-covg --roi-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/gencode_v29_ROI.txt --reference-sequence /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/A_Reference/GRCh38.d1.vd1.fa --bam-list /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/bam_lists_by_subgroup/reformatted/UCEC_msi_bamlist.txt --output-dir /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running`

<b>----Run "bmr calc-bmr" to measure overall + per gene mutation rates----</b>
This will output the files "gene_mrs" and "overall_bmrs". 

`music2 bmr calc-bmr --roi-file ROI_FILE_HERE --reference-sequence REFERENCE_FASTA_HERE --bam-list BAM_LIST_HERE --maf-file MAF_FILE_HERE --output-dir OUTPUT_DIRECTORY_HERE --show-skipped`

Remember to reformat MAFs so that the sample ID for tumor samples match that of the bam list!
To remove "_T" from the tumor IDs in vim:

`:%s/_T//g`

Example for UCEC MSI:

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/logs/log_get_overall_mut_rates.txt music2 bmr calc-bmr --roi-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/gencode_v29_ROI.txt --reference-sequence /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/image.data/A_Reference/GRCh38.d1.vd1.fa --bam-list /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/bam_lists_by_subgroup/reformatted/UCEC_msi_bamlist.txt --maf-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/mafs_by_subgroup/UCEC_msi_formatted.maf --output-dir /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running --show-skipped`

<b>----Run "music2 smg" to get list of SMGs----</b>
For an FDR cut-off of 0.05:

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo LOG_FILE_HERE music2 smg --gene-mr-file GENE_MRS_FILE_HERE --output-file SMG_OUTPUT_FILE_HERE --max-fdr 0.05`

The "GENE_MRS_FILE" is an output from the previous step, "music2 bmr calc-bmr". 
This will output the files "smgs", "smgs_detailed", "smgs_test_qq_plot.pdf", "corrected_smg_test_qq_plot.pdf"

EXAMPLE for UCEC MSI:

`bsub -q research-hpc -n 1 -R "select[mem>30000] rusage[mem=30000]" -M 30000000 -a 'docker(juliatjwang/music2:fixed_withR)' -oo /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/logs/log_run_smg.txt music2 smg --gene-mr-file gene_mrs --output-file /gscmnt/gc2532/dinglab/jwang/CPTAC3/UCEC_SMG/msi/music2_smg_running/smgs --max-fdr 0.05`

