# Model sketch — Example 1: Buenrostro et al. 2013 (ATAC-seq accessibility tracks)

Compare with your answer to question 3 in the README.

| Step | What happens | Input | Output | Hidden choices |
|---|---|---|---|---|
| 1 | Get aligned reads for each assay | Accessions (GEO for ATAC; ENCODE for DNase, FAIRE) | One BAM per assay | Which samples (cell input, replicates); genome build; reprocess or use existing BAMs |
| 2 | Sort and index | BAMs | Coordinate-sorted BAMs with `.bai` indexes | Sort by coordinate (required for indexing and for `bamCoverage`) |
| 3 | Make a signal track | Sorted, indexed BAMs | Coverage per bin (bigwig) | bin size |
| 4 | Scale| Normalized bigwigs | 0–1 tracks | Window max (local) vs. genome-wide max or other choice? |
