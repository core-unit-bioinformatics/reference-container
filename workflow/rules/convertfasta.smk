TRANSFORM_NO_CHR_PREFIX = config.get("convert_fasta", False)
assert isinstance(TRANSFORM_NO_CHR_PREFIX, bool)

# specific workflow to rename the header of the whole chromosomes to
# the standard name (chr#) that is required in some downstream tools

if TRANSFORM_NO_CHR_PREFIX:

    rule create_list_for_replacement:
# This rule creates a table that contains the Genbank Accession ID (column 5) and
# the chromosome number (column 10) from the assembly-report file that belongs to the
# genome. This table will be used to find fasta headers that contain the Genbank
# Accession ID and replace the whole header with just the Chromosome identifier.
# If the required information are not in the designated columns in the assembly-report file
# the appropiate columns need to be specified in the awk command.
        input:
            "payload/ftp/{strainID}.assembly-report.txt",
        output:
            temp("payload/local/{strainID}_replacement.tsv"),
        shell:
            """
            awk '$10 ~ /^chr..{{1,2}}$/ {{print $5"\t"$10}}' {input} > {output}
            """

    rule modify_fasta_file:
# This rule finds the fasta headers that contain the Genbank
# Accession ID of the full chromosomes and replace the whole header with just the Chromosome identifier.
# The original fasta will be saved with an additional "_original" tag to the sample ID.
# This file will be added to the MANIFEST and the container.
        input:
            fasta="payload/ftp/{strainID}.fasta",
            replacement="payload/local/{strainID}_replacement.tsv",
        output:
            original="payload/local/{strainID}_original.fasta",
            modified=temp("payload/local/{strainID}.fasta"),
        shell:
            "cp {input.fasta} {output.original}"
            """
            awk 'FNR==NR {{f2[$1]=$2;next}} 
            /^>/ {{ 
                for (i in f2) {{ 
                    if (index(substr($1,2), i)) {{ 
                        print ">"f2[i]; next 
                    }} 
                }}
            }}1' {input.replacement} {output.original} > {output.modified}
            """
            "cp {output.modified} {input.fasta}"

    rule create_conversion_table:
# This rule creates a conversion table that contains the original fasta header, the Genbank Accession ID and the
# new fasta header will be created. In the process some temp files will be generated but ultimately deleted.
# The conversion table will be added to the MANIFEST and the container.
        input:
            replacement="payload/local/{strainID}_replacement.tsv",
            original="payload/local/{strainID}_original.fasta",
        output:
            header=temp("payload/local/{strainID}_original_headers.tsv"),
            intermediate=temp("payload/local/{strainID}_conversion_table_temp.tsv"),
            final="payload/local/{strainID}_conversion_table.tsv",
        shell:
            """
            awk 'FNR==NR {{f2[$1]=$2;next}} 
            /^>/ {{ 
                for (i in f2) {{ 
                    if (index(substr($1,2), i)) {{ 
                        print; next 
                    }} 
                }}
            }}' {input.replacement} {input.original} > {output.header}
            """
            "paste {output.header} {input.replacement} > {output.intermediate}"
            """
            awk 'BEGIN{{print "original header\tAccessionID\tnew header"}}1' {output.intermediate} > {output.final}
            """

    rule create_dict_file:
# Since Snakemake can't handle two derive commands the creation of the fasta.fai and fasta.dict files have to be
# created separately. This rule and the next one create the afformentioned files based on the newly created the Genbank Accession ID and the
# fasta file with the modified headers. Those files together with the md5 files will be added to the MANIFEST and the container.
        input:
            "payload/local/{strainID}.fasta",
        output:
            "payload/local/{strainID}.fasta.dict",
        container:
            "https://depot.galaxyproject.org/singularity/samtools:1.6--hb116620_7"
        shell:
            "samtools dict {input} > {output}"

    rule create_fai_file:
        input:
            "payload/local/{strainID}.fasta",
        output:
            "payload/local/{strainID}.fasta.fai",
        container:
            "https://depot.galaxyproject.org/singularity/samtools:1.6--hb116620_7"
        shell:
            "samtools faidx {input}"
