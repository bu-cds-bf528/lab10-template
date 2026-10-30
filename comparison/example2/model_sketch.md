# Model sketch — Example 2: GC/AT content near promoters across species

Compare with your answer to question 3 in the README.

| Step | What happens | Input | Output | Hidden choices |
|---|---|---|---|---|
| 1 | Make a GC track for each species | Genome FASTA (or a precomputed track, e.g. UCSC `gc5Base`) | GC per window (bigwig) | Assembly version; window size; overlapping vs. non-overlapping windows; percent vs. fraction |
| 2 | Define the regions | Gene annotation (GTF) for each species | Gene BED with strand | Annotation source (RefSeq, Ensembl, FlyBase); same source for both species; coding only (NM_) vs. all; one transcript per gene, and which (longest?) |
| 3 | Extract signal over regions | GC track + gene BED | Matrix of genes × bins | Mode (`scale-regions` vs. `reference-point`); body length per species; flank size; bin sizes |
| 4 | Summarize across genes | Matrix | Average profile and/or heatmap | Mean (Default) vs. median |
