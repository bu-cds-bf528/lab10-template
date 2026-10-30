#!/usr/bin/env python3
"""Print the median region length in a BED file, rounded to the nearest
multiple of --round-to so it is divisible by every computeMatrix --binSize.
"""
import argparse
import statistics

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('-i', '--input', required=True, help='BED file of regions')
parser.add_argument('-r', '--round-to', type=int, required=True, help='round the median to a multiple of this')
args = parser.parse_args()

bed = args.input
round_to = args.round_to

# BED columns: chrom, start, end, ... so length = end - start
lengths = []
with open(bed) as f:
    for line in f:
        fields = line.split('\t')
        lengths.append(int(fields[2]) - int(fields[1]))

median = statistics.median(lengths)

# Round to the nearest multiple of round_to, but never below round_to
rounded = int(median / round_to + 0.5) * round_to
print(max(rounded, round_to))
