rule rawFastQC_R1:
    input: lambda wc: fq1_dict[wc.sample]
    output:
        html="results/fastQC/raw/{sample}_1_raw_fastqc.html",
        zip="results/fastQC/raw/{sample}_1_raw_fastqc.zip"
    log: "results/logs/rawFastQC_{sample}_R1.log"
    conda: "../envs/qc_env.yaml"
    wrapper: "v3.13.0/bio/fastqc"

rule rawFastQC_R2:
    input: lambda wc: fq2_dict[wc.sample]
    output:
        html="results/fastQC/raw/{sample}_2_raw_fastqc.html",
        zip="results/fastQC/raw/{sample}_2_raw_fastqc.zip"
    log: "results/logs/rawFastQC_{sample}_R2.log"
    conda: "../envs/qc_env.yaml"
    wrapper: "v3.13.0/bio/fastqc"

rule processReads:
    input:
        fq1 = lambda wc: fq1_dict[wc.sample],
        fq2 = lambda wc: fq2_dict[wc.sample],
        adapters = "resources/TruSeq3-PE.fa"
    output:
        f_p = "results/trimmed/{sample}_1_trimmed.fastq", 
        f_un = "results/trimmed/{sample}_1_unpaired_trimmed.fastq", 
        r_p = "results/trimmed/{sample}_2_trimmed.fastq", 
        r_un = "results/trimmed/{sample}_2_unpaired_trimmed.fastq" 
    conda:
        "../envs/qc_env.yaml"
    log:
        "results/logs/trimmomatic_{sample}.log"
    shell:
        """
        java -jar trimmomatic.jar PE \
        {input.fq1} {input.fq2} \
        {output.f_p} {output.f_un} \
        {output.r_p} {output.r_un} \
        ILLUMINACLIP:{input.adapters}:2:30:10 \
        2> {log} 
        """

rule processedFastQC_R1:
    input: "results/trimmed/{sample}_1_trimmed.fastq"
    output:
        html="results/fastQC/trimmed/{sample}_1_trimmed_fastqc.html",
        zip="results/fastQC/trimmed/{sample}_1_trimmed_fastqc.zip"
    log: "results/logs/trimmedFastQC_{sample}_R1.log"
    conda: "../envs/qc_env.yaml"
    wrapper: "v3.13.0/bio/fastqc"

rule processedFastQC_R2:
    input: "results/trimmed/{sample}_2_trimmed.fastq"
    output:
        html="results/fastQC/trimmed/{sample}_2_trimmed_fastqc.html",
        zip="results/fastQC/trimmed/{sample}_2_trimmed_fastqc.zip"
    log: "results/logs/trimmedFastQC_{sample}_R2.log"
    conda: "../envs/qc_env.yaml"
    wrapper: "v3.13.0/bio/fastqc"