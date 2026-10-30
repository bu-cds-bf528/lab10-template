#!/usr/bin/env nextflow

nextflow.enable.types = true

include { SAMTOOLS_SORT } from './modules/samtools_sort'
include { SAMTOOLS_INDEX } from './modules/samtools_index'
include { DEEPTOOLS_BAMCOVERAGE } from './modules/deeptools_bamcoverage'

// Sort and index each BAM, then make one bigWig per sample for every strategy
// in params.coverage_variants, using the bamCoverage options set for
// DEEPTOOLS_BAMCOVERAGE in nextflow.config
workflow {

    main:

    bams = channel.fromPath(params.bams)
        .splitCsv(header: true)
        .map { row -> record(name: row.name, bam: file(row.bam)) }

    sorted_bams = SAMTOOLS_SORT(bams)

    indexed_bams = SAMTOOLS_INDEX(sorted_bams)

    // One copy of each indexed BAM per strategy, e.g. 3 samples x 4 = 12 tasks
    variants = channel.fromList(params.coverage_variants)

    coverage_inputs = indexed_bams
        .combine(variants)
        .map { s, variant -> record(name: s.name, variant: variant, bam: s.bam, bai: s.bai) }

    coverage_inputs.view()
    coverage_bigwigs = DEEPTOOLS_BAMCOVERAGE(coverage_inputs)


    publish:

    alignments = indexed_bams
    bigwigs = coverage_bigwigs

}

output {
    alignments {
        path 'bam_to_bigwig/bams'
    }
    bigwigs {
        path 'bam_to_bigwig/bigwigs'
    }

}
