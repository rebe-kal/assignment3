rule rawFastQC_R1:
    input: 
        lambda wc: fq1_dict[wc.sample]
    output:
        html="results/quality_control/raw/{sample}_tiny_1_fastqc.html",
        zip="results/quality_control/raw/{sample}_tiny_1_fastqc.zip"
    log: 
        "results/logs/rawFastQC/{sample}_R1.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule rawFastQC_R2:
    input: 
        lambda wc: fq2_dict[wc.sample]
    output:
        html="results/quality_control/raw/{sample}_tiny_2_fastqc.html",
        zip="results/quality_control/raw/{sample}_tiny_2_fastqc.zip"
    log: 
        "results/logs/rawFastQC/{sample}_R2.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

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
        "results/logs/trimmomatic/{sample}.log"
    threads: 4
    shell:
        """
        trimmomatic PE \
        {input.fq1} {input.fq2} \
        {output.f_p} {output.f_un} \
        {output.r_p} {output.r_un} \
        ILLUMINACLIP:{input.adapters}:2:30:10 \
        2> {log} 
        """

rule processedFastQC_R1:
    input: 
        "results/trimmed/{sample}_1_trimmed.fastq"
    output:
        html="results/quality_control/trimmed/{sample}_1_trimmed_fastqc.html",
        zip="results/quality_control/trimmed/{sample}_1_trimmed_fastqc.zip"
    log: 
        "results/logs/trimmedFastQC/{sample}_R1.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule processedFastQC_R2:
    input: 
        "results/trimmed/{sample}_2_trimmed.fastq"
    output:
        html="results/quality_control/trimmed/{sample}_2_trimmed_fastqc.html",
        zip="results/quality_control/trimmed/{sample}_2_trimmed_fastqc.zip"
    log: 
        "results/logs/trimmedFastQC/{sample}_R2.log"
    threads: 4
    conda: 
        "../envs/qc_env.yaml"
    wrapper: 
        "v3.13.0/bio/fastqc"

rule qualimapStats:
    input:
        "results/bam/{sample}.bam"
    output:
        "results/quality_control/qualimapStats/{sample}_qualimap_stats"
    conda:
        "../envs/samtools_env.yaml"
    log:
        "results/logs/qualimapStats/{sample}.html"
    shell:
        "qualimap bamqc -bam {input} -outdir results/qualimapStats -pe 2> {log}"

rule aggregateQC:
    input:
        expand(
            "results/quality_control/raw/{sample}_tiny_1_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/raw/{sample}_tiny_2_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/trimmed/{sample}_1_trimmed_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/trimmed/{sample}_2_trimmed_fastqc.zip",
            sample=SAMPLES
        ),
        expand(
            "results/quality_control/qualimapStats/{sample}_qualimap_stats", 
            sample=SAMPLES
        )
    output: 
        "results/quality_control/aggregated/quality_control_aggregated.html"
    log:
        "results/logs/aggregateQC/aggregateQC.log"
    threads: 1
    conda: 
        "../envs/qc_env.yaml"
    shell:
        "multiqc results/quality_control -o results/quality_control/aggregated -n quality_control_aggregated 2> {log}"
