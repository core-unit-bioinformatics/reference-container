rule all:
    input: 
        "test/genome.dict",
        "test/genome.fa.fai",


Test_data = [
{
    "name": "genome.fa",
    "input": "test/genome.fa",
    "output": "test/genome.dict",
    "shell": "samtools dict {input} > {output}",
    "singularity": "https://depot.galaxyproject.org/singularity/samtools:1.6--hb116620_7",
    "rule_name": "rule_test1"
},
{
    "name": "genome.fa",
    "input": "test/genome.fa",
    "output": "test/genome.fa.fai",
    "shell": "samtools faidx {input}",
    "singularity": "https://depot.galaxyproject.org/singularity/samtools:1.6--hb116620_7",
    "rule_name": "rule_test2",
    } 
]

for DT in Test_data:
    rule derive_test:
        name:
            f"derive_{DT['rule_name']}"
        message:
            f"Deriving data file {DT['name']}"
        input:
            DT["input"],
        output:
            DT["output"],
        container:
            DT["singularity"]
        shell:
            DT["shell"]
