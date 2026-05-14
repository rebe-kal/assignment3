rule convert:
    input:
        "results/sam/{sample}.sam"
    output:
        "results/bam/{sample}.bam"
    conda:
        "../envs/samtools_env.yaml"
    log:
        "results/logs/sam_to_bam/{sample}.log"
    shell:
        "samtools view -bSh -1 {input} > {output} 2> {log}"

rule sort:
    input:
        rules.convert.output
    output:
        "results/bam_sorted/{sample}_sorted.bam"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/sort_bam/{sample}.log"
    shell:
        "samtools sort {input} -o {output} 2> {log}"

rule index:
    input:
        rules.sort.output
    output:
        "results/bam_sorted/{sample}_sorted.bam.bai"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/index_bam/{sample}.log"
    shell:
        "samtools index {input} {output} 2> {log}"

rule mapping:
    input:
        bam=rules.sort.output,
        bai=rules.index.output
    output:
        "results/stats/{sample}.txt"
    conda:
        "../envs/samtools_env.yaml"
    log:
        "results/logs/mapping/{sample}.log"
    shell:
        "samtools idxstats {input.bam} > {output} 2> {log}"

rule filter:
    input:
        bam=rules.sort.output,
        bai=rules.index.output
    output:
        "results/filtered/{sample}_filtered.bam"
    conda:
        "../envs/samtools_env.yaml"
    log: 
        "results/logs/filter/{sample}.log"
    shell:
        "samtools view -b {input.bam} NK_AMKI01000040.1 NK_AMKI01000041.1 > {output} 2> {log}"

