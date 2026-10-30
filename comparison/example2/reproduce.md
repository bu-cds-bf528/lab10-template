# Part F: What would you need to reproduce it? — Example 2: GC/AT content near promoters across species

Compare with your Part F table in the README.

| What you need | What we know (and from where) | Still missing or assumed |
|---|---|---|
| Genome builds | Unknown  | Mouse MM10 and drosophila DM6 was assumed  |
| GC track | gc5base files from UCSC - 5bp windows, non-overlapping | how Ns and masked bases were handled |
| Gene annotation | One row per gene, with strand (heatmap rows) | Source (RefSeq, Ensembl, FlyBase); which genes were included; one transcript per gene, and which one |
| `computeMatrix` mode | `scale-regions`: both TSS and TES are marked (x-axis) | — |
| Flanks | Fly 1 kb, mouse 3 kb (x-axis) | — |
| Gene body length | — | `--regionBodyLength` for each species; whether there are unscaled TSS/TES regions |
| Bin size | — | `--binSize` in `computeMatrix` (a second round of smoothing on top of the windows) |