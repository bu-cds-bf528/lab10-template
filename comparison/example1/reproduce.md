# Part F: What would you need to reproduce it? — Example 1: Buenrostro et al. 2013 (ATAC-seq accessibility tracks)

Compare with your Part F table in the README.

| What you need | What we know (and from where) | Still missing or assumed |
|---|---|---|
| Genome build | hg19 (figure header) | — |
| Locus | chr19 ~36,120,000–36,300,000, 19q13.12 (read off the figure) | Exact start/end coordinates |
| ATAC-seq data | GM12878, 50,000 cells per replicate and 500 cells; GEO GSE47753 | Which replicates were used, and whether they were merged or pooled |
| DNase-seq data | ENCODE/Duke, GM12878 | Which replicate or merged track; whether it was reprocessed or the ENCODE signal track was used as-is |
| FAIRE-seq data | ENCODE/UNC, GM12878  | Same as DNase |
| Read processing | Paired-end ATAC-seq, aligned to hg19 (methods) | Would need to check the original papers or ENCODE pages |
| Coverage track (`bamCoverage`) | — | Bin size; read extension; normalization (`CPM`, `RPKM`, none); smoothing |
| 0–1 scaling | Every track's axis runs 0–1 (figure) | What it was divided by: genome-wide max, max in this window, or something else |
| Display | Looks like a UCSC browser screenshot (layout, gene track) | Genome browser specific settings |
