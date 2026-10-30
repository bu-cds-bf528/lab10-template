# Questions — Example 2: GC/AT content near promoters across species


## Part A: What is the figure trying to say?

1. In one sentence, what claim does this figure support?

**Answer:** GC content around genes follows different patterns in fly and mouse:
mouse genes have a sharp GC peak at the TSS, while fly genes have a
GC dip just upstream of the TSS and at the TES.

2. Is this a quantitative or qualitative claim?

**Answer:** Mostly qualitative: it compares the *shape* of the profiles. The
y-axes are real GC fractions, so you can read approximate values. But the two
panels use different ranges and different gene-relative x-axes, so a direct
quantitative comparison between species isn't supported.

## Sketch the workflow

3. Describe in general terms what you would need to do to make this figure, from
genome sequence to the final heatmap or profile. Aim for 4–7 steps, and list the
choices hidden in each.

**Answer:** See [`model_sketch.md`](model_sketch.md).

## Part B: Available information

4. What quantity is on the y-axis: a fraction, a percent, or something else?

**Answer:** A fraction: GC content as the proportion of G+C bases in a window,
averaged across genes (fly ~0.33–0.49, mouse ~0.40–0.60).

5. What's the theoretical range of that quantity?

**Answer:** 0 to 1. A window can't be more than 100% or less than 0% GC.
Real genome-wide averages sit around 0.4.

6. Are the y-axis ranges the same in the two species' panels? Does this affect
our interpretation of the figure?

**Answer:** No. Fly runs about 0.32–0.50 and mouse 0.35–0.70, and the heatmap
color scales differ as well. This doesn't affect our interpretation since we
are mostly comparing the shape as it differs within each species with each other.

7. Which regions do you think were used for this figure?

**Answer:** Annotated genes for each species (one row per gene or transcript),
from TSS to TES. The x-axis shows `scale-regions` mode (both TSS and TES marked)
with 1 kb flanks for fly and 3 kb for mouse.

## Part C: Thinking through the assumptions

8. Look up each genome's overall GC content. Where does that baseline fall on each
panel?

**Answer:** Mouse is ~42% GC and *D. melanogaster* ~42% 

9. Is the promoter "GC-rich" compared with the whole genome, or compared with its
own neighborhood?

**Answer:** In mouse: the TSS peak (~0.60) is above the genome average and
above its flanks. In fly the TSS is GC-*poor* relative to both. The figure itself
only shows the neighborhood. The genome-wide baseline isn't drawn, so "rich"
means relative to the flanks unless you look up the genome average, like you did
above.

10. What information are you missing about how to reproduce this figure?

**Answer:** The gene annotation and filters (source, which genes, one transcript
per gene), `--regionBodyLength` for each species, `--binSize`, how missing data
was handled, the summary statistic (mean vs. median), and the exact GC track
(window size, step, assembly).

## Inspect the workflow

| Choice | Related question(s) | Your prediction | What the workflow does | Where (process / line) |
|---|---|---|---|---|
| GC track source and window size | 4, 5, 8 | | Uses the precomputed UCSC `gc5Base` bigwigs (5 bp windows) for dm6 and mm10; it doesn't compute GC itself | `gc5base_tracks.csv` |
| Gene set and one transcript per gene | 7 | | RefSeq `NM_` (protein-coding) transcripts from refGene GTFs, deduplicated by identical chrom/start/end/strand. This is *not* one transcript per gene: isoforms with different coordinates are all kept | `GTF_UNIQUE_NM_TRANSCRIPTS` (`bin/gtf_unique_nm_transcripts.py:25–36`) |
| `computeMatrix` mode | 7, 10 | | `scale-regions` | `DEEPTOOLS_COMPUTEMATRIX_SCALEREGIONS` (`modules/deeptools_computematrix_scaleregions/main.nf`) |
| Body length per species (`--regionBodyLength`) | 10 | | Two variants: `species` = that genome's median transcript length; `shared` = the mm10 median used for both. Both are rounded to a multiple of 500 bp | `nextflow.config:12–13`, `nextflow.config:57–62`, `compute_matrix.nf:21–30`, `bin/bed_median_length.py:25–27` |
| Flanks per species (`-b` / `-a`) | 10 | | Fixed per genome: mm10 3000 bp, dm6 1000 bp | `nextflow.config:15`, `nextflow.config:61–63` |
| Bin size (`--binSize`) | 10 | | Sweeps 5, 50 and 500 bp | `nextflow.config:11`, `nextflow.config:62` |

## Part D: Does it change the interpretation?

11. Which choices changed the *shape* of the profile, and which only changed its
height or smoothness?

**Answer:** Bin size mainly changes smoothness: 500 bp bins blur the mouse TSS
peak into a lower, wider bump. Body length changes the shape of the gene-body
section, because features spread out or compress relative to the flanks.

12. In Example 1, changing the scaling didn't change the shape of any track. Here,
changing the bin size and body length did. What's different about these
transformations?

**Answer:** Example 1's scaling multiplies every value by the same constant, so
it is linear and global and can't change shape. Bin size and body length change
*how values are aggregated along the x-axis*: averaging over different sized
windows, and stretching or compressing each gene by a diferent amount. That
redistributes the signal, so narrow features can be distorted.

13. The GC track has 5 bp resolution. What does a profile with a 5 bp bin show? What
would a 1 bp bin show?

**Answer:** A 5 bp bin shows the track at its native resolution, which is limited
by the original bigwig. A 1 bp bin would just repeat each 5 bp value five times. It
looks more detailed, but there's no new information, because the source data has
nothing finer than 5 bp.

14. When fly gene bodies are stretched to mouse's body length, does the profile look
more or less detailed? Is that detail real?

**Answer:** More detailed, because there are more bins across the gene body. The
detail isn't real: fly genes are shorter, so stretching them interpolates or
repeats values. It adds bins without adding information.

15. How do you think the values for flanking (1k for dm6, 3k for mm10) were chosen?

**Answer:**  The values were approximated by around 1/3 of the median size of
genes. 

## Part E: Comparing the species fairly (hypotheticals)

16. Each genome has a different baseline GC content. How would you make "enriched"
mean the same thing in both species?

**Answer:** Express GC relative to each genome's baseline: subtract the genome
mean or divide by it (log2 ratio), or convert to a z-score using genome-wide mean
and SD. Then "enriched" means "above this genome's average" in both. An
alternative is to compare against a matched local background, such as the
flanks.

## Part F: What would you need to reproduce it?

**Answer:** See [`reproduce.md`](reproduce.md).

## Write it up

17. Name the one choice that matters most for comparing the two species, and
explain why.

**Answer:** The choice for what size to scale every gene to. Since mouse genes
tend to be much larger, scaling fly genes to the size of mouse genes would
greatly distort the signal. 

18. Sketch how you would determine that choice if you were reproducing the figure
yourself: **where** would you get the data, **what format** is it in, and **what
would you calculate**?

**Answer:** Get the gene annotation for each species (e.g., from UCSC or
Ensembl) as a GTF or BED file. Calculate the distribution of gene lengths for
each species and compare them. Use a sensible approximation (median, mean) and
scale each species respectively to avoid distorting the data due to structural
differences in the genomes.
