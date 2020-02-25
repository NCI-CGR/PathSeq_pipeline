# vim: ft=python
import os
import glob
import itertools
from collections import defaultdict

configfile: 'totalRNA_config.yaml'
workdir: os.environ['PWD']
shell.executable('bash')

def parse_ID(filename):
    return filename.split('/')[-1].split('_')[0]

allfq = glob.glob(config['fastq_dir'] + config['fastq_glob'])

print(allfq)

d = defaultdict(list)
for key, value in itertools.groupby(allfq, parse_ID):
    d[key] += list(value)


TARGETS = []
include: 'qc_Snakefile'
TARGETS += ['reports/filtered_read_count.tsv']
include: 'align_Snakefile'
TARGETS += ['multiqc/mapping_report.html',
            'multiqc/rnaseqc_report.html',
            'multiqc/rrna_report.html',
            'reports/rnaseqc_v1/report.html',
            'reports/gene_count_summary.tsv',]
TARGETS += expand('salmon_gene_quant/{sampleID}.gene_quant.txt', sampleID=d.keys()),
include: 'pathseq_Snakefile'
TARGETS += ['reports/pathseq_filter_metrics.txt']
TARGETS += expand('pathseq_idxstats/{sampleID}.pathseq.idxstats.txt', sampleID=d.keys())
           

rule all:
    input: TARGETS
