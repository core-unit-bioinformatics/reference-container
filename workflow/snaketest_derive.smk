# Run me
# snakemake --verbose -d wd/  -c 1 --use-singularity --keep-going --rerun-incomplete -s workflow/snaketest_derive.smk

rule all:
    input: 
        "test/genome.fa",
        "test/genome.dict",
        "test/genome.fa.fai",

rule get_test_file:
    output:
        "test/genome.fa"
    shell:
        """
        wget -O {output} https://raw.githubusercontent.com/snakemake/snakemake-tutorial-data/master/data/genome.fa
        """

Test_data = [
{
    "input": "test/genome.fa",
    "output": "test/genome.dict",
    "shell": "samtools dict {input} > {output}",
    "singularity": "https://depot.galaxyproject.org/singularity/samtools:1.15--h1170115_1",
    "rule_name": "create_dict"
},
{
    "input": "test/genome.fa",
    "output": "test/genome.fa.fai",
    "shell": "samtools faidx {input}",
    "singularity": "https://depot.galaxyproject.org/singularity/samtools:1.15--h1170115_1",
    "rule_name": "create_faidx",
}
]

for DT in Test_data:
    print("Building rule")
    print(DT)
    rule:
        name:
            f"{DT['rule_name']}"
        message:
            f"Deriving data file {DT['output']} with CMD {DT['shell']}"
        input:
            DT["input"],
        output:
            DT["output"],
        container:
            DT["singularity"]
        shell:
            DT["shell"]
