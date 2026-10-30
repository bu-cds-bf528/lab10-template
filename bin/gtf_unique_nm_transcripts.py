#!/usr/bin/env python3
"""Write RefSeq NM_ (protein-coding) transcripts from a gzipped GTF as BED6,
keeping one transcript per unique chrom/start/end/strand.
"""
import argparse
import gzip
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('-i', '--input', required=True, help='gzipped GTF annotation')
parser.add_argument('-o', '--output', required=True, help='BED file to write')
args = parser.parse_args()

gtf = args.input
out = args.output

seen = set()
rows = []
with gzip.open(gtf, 'rt') as f:
    for line in f:
        if line.startswith('#'):
            continue
        chrom, source, feature, start, end, score, strand, frame, attributes = line.rstrip('\n').split('\t')

        # Keep transcripts whose ID starts with NM_
        if feature != 'transcript':
            continue
        transcript_id = re.search(r'transcript_id "([^"]+)"', attributes).group(1)
        if not transcript_id.startswith('NM_'):
            continue

        # Skip transcripts with the same coordinates as one already kept
        key = (chrom, start, end, strand)
        if key in seen:
            continue
        seen.add(key)

        # GTF starts are 1-based, BED starts are 0-based
        rows.append((chrom, int(start) - 1, int(end), transcript_id, 0, strand))

# Sort by chromosome, then start
rows.sort(key=lambda row: (row[0], row[1]))

with open(out, 'w') as f:
    for row in rows:
        f.write('\t'.join(str(x) for x in row) + '\n')
