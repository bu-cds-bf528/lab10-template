# Lab 10 - Genomic Visualization

## Objectives

- Learn about the common choices and strategies for normalization, and binning
when generating visualizations of genomic data
- Practice how you would dissect the intent of a figure, and how to go about
reproducing it with various levels of provided information


## Decomposing a Figure

This next section is a series of questions you can apply to thinking about how
to reproduce any figure with some specifics related to our topic for today:
genomic visualization.

**Questions**
1. What is the intent of the figure? In one sentence, what are the authors trying
to convey?

2. What is the input data, and in what file format (BAM, bigwig, BED, FASTA, matrix)?
Where would you obtain it if needed?

3. What transformation produced the plotted values (binning, normalization, etc. )?

4. What tool would you use, and which parameters matter most?

5. What choices are hidden that impact the interpretation but are not obvious? (bin size, replicate merging)

6. Global or local? For each reference the figure relies on, is it computed from the whole genome/sample (global) or from the displayed window or neighborhood (local)?

7. Could this figure have come straight out of a browser, or did someone have to compute something first?

8. What would you need from the methods section to reproduce it exactly?

## The deepTools command

Before you start, here is what the core deepTools step for each figure does at a
high level. Each one has defaults and options that may vastly influence the 
representation of the underlying data. 

### Example 1: `bamCoverage` (BAM → bigwig)

```
bamCoverage -b sample.bam -o sample.bw --binSize 10 --normalizeUsing CPM --extendReads 200
```

- Splits the genome into bins of `--binSize` bp and counts the reads overlapping
  each bin.
- Optionally extends reads to the fragment length (`--extendReads`), skips
  duplicates or low-MAPQ reads, and smooths over neighboring bins (`--smoothLength`).
- Normalizes the counts (`--normalizeUsing`: `None`, `CPM`, `RPKM`, `BPM`, `RPGC`).
- The output is a bigwig of coverage values along the genome. None of the
  normalization options produces a value bounded at 0–1.


## Example 1: Genomic visualization of accessibility assays (Buenrostro et al 2013)

![buenrostro](figure1.png)

You have already seen this figure in the lecture on ATACseq, and now I'm going to
ask you how you would reproduce it and why they made the choices they did. 

This particular figure was not exactly described in the methods and so it's a good
test case for thinking about all of the different assumptions and choices made
when visualizing sequencing data.

Work through the questions below in order with your group.

### Part A: What is the figure trying to say?

1. In one sentence, what claim does this panel support?
2. Is this a quantitative or qualitative claim?

### Part B: Available information

3. What units are one each axis and what do they represent?
4. What does the axis scale of 0-1 imply for this figure?
5. Does the methods reveal how this figure was generated?


### Part C: Thinking through the assumptions

5. List the ways you could produce a 0–1 axis from coverage data.

6. For each one, is the reference **global** (computed from the whole genome or
library) or **local** (computed from this window)?

7. Look closely at the peaks. Does any track's tallest peak reach exactly 1? Does
every track's?

8. If each track had been scaled to its genome-wide maximum, what would you expect
an ordinary locus to look like?

9. How likely is it that the genome-wide maximum of three different assays falls
in this one window?

10. Read the text: how did the authors choose this locus?

11. Based on 8-10, which scaling does the evidence favor? How confident are you, and
could the figure alone settle it?

### Part E: Does it change the interpretation?

12. What *can* you conclude from this figure, and what can't you?

13. What does this scaling preserve within each track, and what does it lose between
tracks?

14. Would the conclusion look the same at a different locus? What would you need to
show to make the claim genome-wide?

15. Look at the paper, what did they do to follow-up on this figure.

### Part F: Plan the reproduction

16. What input data do you need, and in what format? Where would you get each file?

### Part G: The missing sentence

17. From the above questions, which details would be needed to exactly reproduce
the figure?

### Part H: Strengthening the conclusion (hypotheticals)

The figure shows one locus. Suppose the authors wanted the claim "ATAC-seq has
signal-to-noise comparable to DNase-seq" to hold genome-wide, not just here.

| Approach | What it fixes | New choices it introduces | Could they change the answer? |
|---|---|---|---|
| **Correlation between bigwigs** (`multiBigwigSummary` → `plotCorrelation`) | Locus dependence: compares assays everywhere at once, with no scaling to choose | Genome-wide bins vs. peak regions only; bin size; Pearson vs. Spearman; log transform; how zeros are handled | **Yes.** Genome-wide bins are mostly near-zero background, which can inflate agreement; Pearson is dominated by the tallest bins. Correlation at peaks asks a different question than correlation everywhere. |
| **Aggregate profile at a region set** (`computeMatrix` → `plotProfile`, e.g. at all DNase peaks or TSSs) | One locus → thousands; shows average peak-to-flank contrast | Which region set (whose peaks? defines the answer); flank size; normalization; mean vs. median | **Yes.** Using DNase peaks as the reference set favors DNase-like signal. |
| **Overlap with a reference peak set** (Venn/UpSet, or ROC against DNase peaks) | Sensitivity and specificity genome-wide | Reference set treated as truth; overlap definition (1 bp vs. 50%) | **Yes.** Treating DNase as ground truth assumes the thing being tested. |

### Part I: What would you need to reproduce it?

| What you need | What we know (and from where) | Still missing or assumed |
|---|---|---|
| Genome build | hg19 (figure header) | — |
| Locus | chr19 ~36,120,000–36,300,000, 19q13.12 (read off the figure) | Exact start/end coordinates |
| ATAC-seq data | GM12878, 50,000 cells per replicate and 500 cells; GEO GSE47753 | Which replicates were used, and whether they were merged or pooled |
| DNase-seq data | ENCODE/Duke, GM12878 (UCSC `wgEncodeOpenChromDnase`) | Which replicate or merged track; whether it was reprocessed or the ENCODE signal track was used as-is |
| FAIRE-seq data | ENCODE/UNC, GM12878 (UCSC `wgEncodeOpenChromFaire`) | Same as DNase |
| Histone/CTCF tracks | ENCODE, GM12878 (likely Broad histone tracks on UCSC) | Exact lab and files; how the four marks were overlaid |
| Read processing | Paired-end ATAC-seq, aligned to hg19 (methods) | Duplicate removal; MAPQ filter; Tn5 shift; fragment vs. read coverage |
| Coverage track (`bamCoverage`) | — | Bin size; read extension; normalization (`CPM`, `RPKM`, none); smoothing |
| 0–1 scaling | Every track's axis runs 0–1 (figure) | What it was divided by: genome-wide max, max in this window, or something else |
| Display | Looks like a UCSC browser screenshot (layout, gene track) | Browser windowing function (mean vs. max); smoothing; whether any track was clipped |


## Example 2: GC/AT content near promoters across species

![species](figure2.png)

This figure was generated from the genomic sequence and represents the GC
content calculated across the genome in non-overlapping windows of 5bp. The 
figure shows a characteristic difference in GC content relative to the gene bodies
in different species. 

### Example 2: `computeMatrix` (bigwig + regions → matrix)

```
computeMatrix scale-regions -S GCcontent.bw -R genes.bed \
  --regionBodyLength 5000 -b 3000 -a 3000 --binSize 50 -o matrix.gz
```

- Takes a signal track (bigwig) and a set of regions (BED/GTF) and pulls out the
  signal over each region, binned into a genes × bins matrix.
- In `reference-point` mode, every region is anchored at one point (e.g. the TSS)
  and the flanks are measured in real base pairs.
- In `scale-regions` mode, every gene body is stretched or compressed to the same
  length (`--regionBodyLength`), with fixed-size flanks (`-b`/`-a`) on either side.
- The matrix is then summarized by `plotProfile` (average across genes) or
  `plotHeatmap` (one row per gene).

### Sketch the workflow

Describe in general terms what you would need to do to make this figure, from
genome sequence to the final heatmap or profile. Aim for 4–7 steps, and list the
choices hidden in each.

| Step | What happens | Input | Output | Hidden choices |
|---|---|---|---|---|
| 1 | Make a GC track for each species | Genome FASTA (or a precomputed track, e.g. UCSC `gc5Base`) | GC per window (bigwig) | Assembly version; window size; overlapping vs. non-overlapping windows; which coordinate a window's value is assigned to; how Ns and masked bases are handled; percent vs. fraction |
| 2 | Define the regions | Gene annotation (GTF) for each species | Gene BED with strand | Annotation source (RefSeq, Ensembl, FlyBase); same source for both species; coding only (NM_) vs. all; one transcript per gene, and which (longest?); drop unplaced contigs |
| 3 | Extract signal over regions | GC track + gene BED | Matrix of genes × bins | Mode (`scale-regions` vs. `reference-point`); body length per species; flank size; unscaled TSS/TES region; bin size; missing data as zero or missing; skip all-zero genes |
| 4 | Summarize across genes | Matrix | Average profile and/or heatmap | Mean vs. median; sort order and clustering for the heatmap |
| 5 | Set the reference | Profile per species | Comparable profiles | Absolute GC vs. centered on each genome's mean vs. relative to flanking sequence |
| 6 | Display | Profiles and heatmaps | The figure | Shared vs. per-species y-axis or color limits (`--zMin`/`--zMax`); color map; panel layout; labeling the x-axis units (bp vs. gene-relative) |

Which steps do you expect to change the *shape* of the profile, and which only its
height or colors?

### Part A: Read the axes

1. What quantity is on the y-axis: a fraction, a percent, or something else?
2. What's the theoretical range of that quantity?
3. Are the y-axis ranges the same in the two species' panels? Does this affect
our interpretation of the figure?

### Part B: What's a sensible value?

4. Before looking anything up, what would you expect GC content to be genome-wide?
At a CpG island?
5. Look up each genome's overall GC content. Where does that baseline fall on each
panel?
6. If a value were outside 0–1, what would that tell you about how it was computed?
7. Should GC + AT = 1 everywhere? When might it not? (Think about Ns and masked
sequence.)
8. If AT is roughly 1 − GC, what does plotting both add?

### Part C: How was the signal made?

9. The file is called `GCcontent_Mm9_50_5.bw`. What might 50 and 5 mean?
10. What happens to the TSS spike if the windows were 500 bp instead? 5 kb?
11. `computeMatrix` also has a `--binSize`. How many layers of smoothing are in this
figure?

### Part D: Global vs. local reference

12. Is the promoter "GC-rich" compared with the whole genome, or compared with its
own neighborhood?
13. How would the figure change if each species were centered on its genome-wide
mean? On its own flanking sequence?
14. Which version answers "are mouse promoters more GC-enriched than fly promoters?"

### Part E: The x-axis

15. The flanks and body length differ between species. Why might they have been set
from each species' median gene size?
16. Is the TSS spike's *width* comparable between panels? Is a CpG island's physical
size different in mouse and fly?
17. Which features would you compare in base pairs, and which in gene-relative units?


### Part F: What would you need to reproduce it?

| What you need | What we know (and from where) | Still missing or assumed |
|---|---|---|
| Genome builds | Mouse mm9 (from the file name `GCcontent_Mm9_50_5.bw`) | Fly assembly (probably dm3, the build current at the same time) |
| GC track | Values are fractions, roughly 0.2–0.7 (axes); likely 50 bp windows with a 5 bp step (file name) | Window size and step confirmed; overlapping or not; how Ns and masked bases were handled |
| Gene annotation | One row per gene, with strand (heatmap rows) | Source (RefSeq, Ensembl, FlyBase); which genes were included; one transcript per gene, and which one |
| `computeMatrix` mode | `scale-regions`: both TSS and TES are marked (x-axis) | — |
| Flanks | Fly 1 kb, mouse 3 kb (x-axis) | — |
| Gene body length | — | `--regionBodyLength` for each species; whether there are unscaled TSS/TES regions |
| Bin size | — | `--binSize` in `computeMatrix` (a second round of smoothing on top of the windows) |
| Missing data | — | Missing values treated as zero or skipped; all-zero genes dropped |
| Summary | One average profile per species (top panels) | Mean vs. median |
| Heatmap | Separate color limits per species (fly ~0.2–0.64, mouse ~0.23–0.68); yellow-green-blue color map | Sort order (default: descending mean); `--zMin`/`--zMax`, or autoscaled |
| Profile y-axis | Different for each species (fly 0.33–0.50, mouse 0.4–0.7) | Set by hand or autoscaled |
