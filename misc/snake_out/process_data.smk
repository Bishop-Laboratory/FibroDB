import re
import os
import glob
import pandas as pd
import math

# TODO: Should be parameterized in the future
genome_home_dir = "/home/millerh1/genomes/for_uchida/"

samplesheet = pd.read_csv("samples.csv")
samples = samplesheet['sample_id']
paired_end = samplesheet['paired_end']


def pe_test_fastp(wildcards):
  pe = [paired_end[idx] for idx, element in enumerate(samples) if element == wildcards.sample][0]
  if pe:
      res="--interleaved_in "
  else:
      res=""
  return res


def check_star_inputs(wildcards):
  if not test_pe(wildcards):
    retlist=["fastqs_prepped/" + wildcards.sample + "/" + wildcards.sample + ".R1.fastq"]
  else:
    retlist=[
      "fastqs_prepped/" + wildcards.sample + "/" + wildcards.sample + ".R1.fastq", 
      "fastqs_prepped/" + wildcards.sample + "/" + wildcards.sample + ".R2.fastq"
    ]
  return retlist


def test_pe(wildcards):
  return [paired_end[idx] for idx, element in enumerate(samples) if element == wildcards.sample][0]


rule output:
    input: 
      degs="degs.csv",
      counts="counts.csv"
      
      
rule downstream:
  input:
    counts=expand("counts/{sample}.{ext}", sample=samples, ext=['counts.tsv']),
    samples="samples.csv",
    contrasts="contrasts.csv",
    gtf=genome_home_dir + "Homo_sapiens.GRCh38.103.gtf"
  conda: "envs/edger.yaml"
  log: "logs/downstream.log"
  output:
    degs="degs.csv",
    counts="counts.csv"
  script: "scripts/downstream.R"
    
    
rule cleanup_star:
  input:
      bam="star_raw/{sample}/Aligned.sortedByCoord.out.bam",
      cts="star_raw/{sample}/ReadsPerGene.out.tab"
  output:
      bam="star/{sample}.bam",
      bai="star/{sample}.bam.bai",
      cts="counts/{sample}.counts.tsv"
  conda: "envs/samtools.yaml"
  shell: """
      mv {input.bam} {output.bam}
      samtools index {output.bam}
      mv {input.cts} {output.cts}
  """

    
rule star_align_reads:
  input: 
    file="fastqs_prepped/{sample}/{sample}.R1.fastq",
    index=genome_home_dir + "star_index/SA",
  output: 
    bam=temp("star_raw/{sample}/Aligned.sortedByCoord.out.bam"),
    cts="star_raw/{sample}/ReadsPerGene.out.tab"
  log: "logs/star_splice/{sample}.log"
  params:
      # path to STAR reference genome index
      # optional parameters
      outdir="star_raw/{sample}/",
      index=genome_home_dir + "star_index/",
      gtf=genome_home_dir + "Homo_sapiens.GRCh38.103.gtf",
      files=check_star_inputs
  threads: 8
  conda: "envs/star.yaml"
  shell: """
  (
    STAR --runMode alignReads --runThreadN {threads} --genomeDir {params.index} \
    --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts \
    --outReadsUnmapped Fastx --sjdbGTFfile {params.gtf} --readFilesIn {params.files} \
    --outFileNamePrefix {params.outdir}
  ) &> {log}
  """
    

rule cleanup_fq:
  input: "fastqs_trimmed/{sample}.fastq"
  output: "fastqs_prepped/{sample}/{sample}.R1.fastq"
  conda: "envs/bbmap.yaml"
  log: "logs/cleanup_fq/{sample}__cleanup_fq.log"
  params:
    ispe=test_pe,
    outdir="fastqs_prepped/{sample}"
  shell: """
  (
    if [ {params.ispe} == "True" ]; then
      reformat.sh ow=t in={input} out1={params.outdir}/{wildcards.sample}.R1.fastq \
      out2={params.outdir}/{wildcards.sample}.R2.fastq
    else
      mv {input} {output}
    fi
  ) &> {log}
  """

    
rule star_index:
  input: 
    fasta=genome_home_dir + "Homo_sapiens.GRCh38.dna.primary_assembly.fa",
    gtf=genome_home_dir + "Homo_sapiens.GRCh38.103.gtf"
  output:
    index=genome_home_dir + "star_index/SA"
  threads: 40
  params:
    outdir=genome_home_dir + "star_index/"
  conda: "envs/star.yaml"
  shell: """
    STAR --runMode genomeGenerate --runThreadN {threads} --genomeDir {params.outdir} \
    --genomeFastaFiles {input.fasta} --sjdbGTFfile {input.gtf}
  """
    

rule download_annotations:
  output: 
    fasta=genome_home_dir + "Homo_sapiens.GRCh38.dna.primary_assembly.fa",
    gtf=genome_home_dir + "Homo_sapiens.GRCh38.103.gtf"
  shell: """
    wget -O {output.fasta}.gz http://ftp.ensembl.org/pub/release-103/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
    wget -O {output.gtf}.gz http://ftp.ensembl.org/pub/release-103/gtf/homo_sapiens/Homo_sapiens.GRCh38.103.gtf.gz
    gunzip {output.fasta}.gz 
    gunzip {output.gtf}.gz
  """

    
rule fastp:
  input: "fastqs_raw/{sample}/{sample}.fastq"
  output:
      trimmed=temp("fastqs_trimmed/{sample}.fastq"),
      html="QC/fastq/html/{sample}.html",
      json="QC/fastq/json/{sample}.json"
  conda: "envs/fastp.yaml"
  log: "logs/fastp/{sample}__fastp_pe.log"
  priority: 10
  params:
      extra=pe_test_fastp
  threads: 4
  shell: """
  (fastp -i {input} --stdout {params.extra}-w {threads} -h {output.html} -j {output.json} > {output} ) &> {log}
  """


rule sra_to_fastq:
  input: "sras/{sample}/{sample}.sra"
  output: temp("fastqs_raw/{sample}/{sample}.fastq")
  conda: "envs/sratools.yaml"
  threads: 1
  log: "logs/sra_to_fastq/{sample}__sra_to_fastq.log"
  params:
      output_directory="sras/{sample}/",
      fqdump="--skip-technical --defline-seq '@$ac.$si.$sg/$ri' --defline-qual '+' --split-3 "
  shell: """(
    cd {params.output_directory}
    fastq-dump {params.fqdump}-O ../../fastqs_raw/{wildcards.sample}/ {wildcards.sample}
    cd ../../fastqs_raw/{wildcards.sample}/
    if test -f {wildcards.sample}_2.fastq; then
        echo "Paired end -- interleaving"
        reformat.sh in1={wildcards.sample}_1.fastq in2={wildcards.sample}_2.fastq out={wildcards.sample}.fastq overwrite=true
        rm {wildcards.sample}_1.fastq && rm {wildcards.sample}_2.fastq
    else
        echo "Single end -- finished!"
    fi
  ) &> {log}
  """   
        
        
rule download_sra:
  output: "sras/{sample}/{sample}.sra"
  conda: "envs/sratools.yaml"
  log: "logs/download_sra/{sample}__download_sra.log"
  params:
      output_directory = "sras/"
  threads: 10
  shell: """
          (
          cd {params.output_directory}
          prefetch {wildcards.sample} -f yes
          ) &> {log}
          """
