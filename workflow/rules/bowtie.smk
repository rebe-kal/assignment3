rule indexReference:
    input:
        ref = config["ref"]
    output:
            multiext("results/index/genome",".1.bt2",".2.bt2",".3.bt2",".4.bt2",".rev.1.bt2",".rev.2.bt2")
    params:
        index_base = "results/index/genome"
    conda:
        "../envs/bowtie2_env.yaml"
    threads: 4
    log: 
        "results/logs/bowtie2_index.log"
    shell:
        "bowtie2-build --threads {threads} {input.ref} {params.index_base} 2> {log}"

rule pairEnd:
    input:
        fq1 = lambda wildcards: fq1[wildcards.sample],
        fq2 = lambda wildcards: fq2[wildcards.sample],
        index = multiext("results/index/genome", ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2")
    output:
        temp(ensure(
            "results/sam/{sample}.sam",
            non_empty=True
            ))
    conda:
        "../envs/bowtie2_env.yaml"
    threads: 4 
    log: 
        "results/logs/bowtie2_map/{sample}.log"
    params:
        index_prefix="results/index/genome",
        N = config["bowtie2_params"]["N"],
        L = config["bowtie2_params"]["L"],
        D = config["bowtie2_params"]["D"],
        R = config["bowtie2_params"]["R"]
    shell:
        """
        bowtie2 -p \
            --threads {threads} \
            -x {params.index_prefix} \
            -1 {input.fq1} -2 {input.fq2} \
            -S {output} \
            -N {params.N} \
            -L {params.L} \
            -D {params.D} \
            -R {params.R} \
            2> {log}
        """