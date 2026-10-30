# Questions — Example 1: Buenrostro et al. 2013 (ATAC-seq accessibility tracks)

## Part A: What is the figure trying to say?

1. In one sentence, what claim does this panel support?

**Answer:** At a representative locus, ATAC-seq from 50,000 cells (and even 500
cells) shows open-chromatin peaks in the same places as DNase-seq, with a similar
or better signal-to-noise ratio than DNase-seq and FAIRE-seq.

2. Is this a quantitative or qualitative claim?

**Answer:** Qualitative. It is a visual comparison at one locus that shows concordance
with the peaks and the background signal between all the assays. 

## Sketch the workflow

3. Describe in general terms what you would need to do to make this panel, from
raw data to the final figure. Hidden choices are choices that you may not be able
to determine directly from the figure.

**Answer:** See [`model_sketch.md`](model_sketch.md).

## Part B: Available information

4. What units are on each axis and what do they represent?

**Answer:** The x-axis is genomic position on chr19 (hg19) in bp, about
36,120,000–36,300,000 (~180 kb, 50 kb scale bar). The y-axis has no units: each
track runs 0–1, which is normalized signal (coverage divided by some reference).

5. What does the axis scale of 0-1 imply for this figure?

**Answer:** Each track has been divided by some maximum (or rescaled), so values
are relative *within* a track. A 1 in ATAC-seq and a 1 in FAIRE-seq don't mean the
same amount of signal. Absolute heights, sequencing depth and how many reads fall
in this window are all hidden. Only shape and peak-to-background contrast within
each track can be read off.

6. Does the methods reveal how this figure was generated (https://pmc.ncbi.nlm.nih.gov/articles/PMC3959825/)?

**Answer:** No. The methods describe the library prep, sequencing, alignment and
peak calling, but not how the tracks in this panel were made: no bin size, read
extension, normalization or 0–1 scaling.

7. What choices were made that are not easily determined from the figure alone?

**Answer:** Bin Size, what the 0–1 scaling divides by (window vs. chromosome vs.
genome max), which replicates were used or merged, and how the locus was chosen.

## Part C: Thinking through the assumptions

8. List the ways you could produce a 0–1 axis from coverage data.

**Answer:**
- Divide by the maximum in the displayed window.
- Divide by the genome-wide (or chromosome-wide) maximum.


9. For each one, is the reference **global** (computed from the whole genome or
library) or **local** (computed from this window)?

**Answer:** Window max is local, genome-wide or chromosome wide are "global"

10. Does any track's tallest peak reach exactly 1? Does every track's?

**Answer:** Yes. In each track the tallest peak reaches (or nearly reaches) 1.

11. If each track had been scaled to its genome-wide maximum, what would you expect
an ordinary locus to look like?

**Answer:** Much flatter since the genome-wide value is likely relatively large.

12. How likely is it that the genome-wide maximum of three different assays falls
in this one window?

**Answer:** Unlikely. The window is only ~180 kb of the entire genome.

13. Read the text: how did the authors choose this locus?

**Answer:** The text doesn't give a selection procedure; the locus
is presented as a representative example. Without a stated procedure, assume it
could have been picked because it looks clean and supports their conclusions.

14. Based on 10–13, which scaling does the evidence favor? How confident are you, and
could the figure alone settle it?

**Answer:** Local maximum in the window. Fairly confident, because every track
has a maximum value and it seems unlikely they would have by chance found the locus
where they saw the maximum signal. The figure alone can't tell us this, this is
my speculation.

## Inspect the workflow

| Choice | Related question(s) | Your prediction | What the workflow does | Where (process / line) |
|---|---|---|---|---|
| Bin size (`--binSize`) | 7 | | Not set, so bamCoverage's default of 50 bp is used | `DEEPTOOLS_BAMCOVERAGE` (`modules/deeptools_bamcoverage/main.nf:24`) |
| 0–1 scaling, and what it divides by | 8–14 | | Makes four variants: `raw` (no scaling), `globalmax` and `windowmax` (`--scaleFactor` 1/max), and `cpm` (`--normalizeUsing CPM`) | `nextflow.config:22`, `nextflow.config:44–47` |
| Region the reference is computed over (window, chr19, genome) | 9, 14 | | `globalmax` uses the max over all of chr19, not the genome (the BAMs only cover chr19); `windowmax` uses the figure's window. Both maxima are hard-coded and not computed by the workflow | `nextflow.config:25–26` |

## Part D: Does it change the interpretation?

15. What *can* you conclude from this figure, and what can't you?

**Answer:** You *can* conclude that at this locus ATAC-seq peaks fall in the same
places as DNase-seq peaks, and that its background looks low relative to its own
peaks (lower than FAIRE-seq). You *can't* compare signal strength between assays,
say anything genome-wide, or measure signal-to-noise. Some of the visible contrast
also depends on display choices you can't see.

16. What does this scaling preserve within each track, and what does it lose between
tracks? Did changing the scaling change the *shape* of any track?

**Answer:** Dividing by a constant preserves each track's shape, peak positions
and relative peak heights (peak-to-background ratio). It loses absolute values and
any comparison of heights between tracks.

17. Would the conclusion look the same at a different locus? What would you need to
show to make the claim genome-wide?

**Answer:** Not necessarily. Another locus could have weaker ATAC peaks, peaks
DNase doesn't have, or a noisier background. To make the claim genome-wide you'd
need a summary over many regions: correlation of signal in bins, an aggregate
profile at a region set, or the overlap of peak calls (see Part E).

18. Look at the paper, what did they do to follow-up on this figure?

**Answer:** They looked at peak correlations and intersections of peaks. 

## Part E: Strengthening the conclusion (hypotheticals)

19. Pick one approach below. At a high level, what would you do, and which of the
new choices it introduces worries you most?

**Answer:** Make normalized bigwigs for each assay, summarize them in genome-wide bins
with `multiBigwigSummary`, and plot Spearman correlations with `plotCorrelation`. 

## Part F: What would you need to reproduce it?

**Answer:** See [`reproduce.md`](reproduce.md).

## Write it up

20. Name the one choice that matters most for this figure's claim, and explain why.

**Answer:** The 0–1 scaling, and specifically whether its reference is local
(window max) or global.

21. Sketch how you would determine that choice if you were reproducing the figure
yourself. Answer in plain words: **where** would you get the data, **what format**
is it in, and **what would you calculate**?

**Answer:** Get the ATAC-seq reads from GEO (GSE47753) and the DNase-seq and
FAIRE-seq BAMs or signal tracks from ENCODE/UCSC (GM12878, hg19). Make bigwigs
with `bamCoverage` (no scaling). Calculate each track's maximum in the figure's
window and across chr19 or the genome. Divide by each and compare with the
figure: if the window max makes every peak hit 1 and the global max makes the
locus look flat, the authors used the local window max. 
