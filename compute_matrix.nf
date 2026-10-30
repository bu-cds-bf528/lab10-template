#!/usr/bin/env nextflow

nextflow.enable.types = true

include { GTF_UNIQUE_NM_TRANSCRIPTS } from './modules/gtf_unique_nm_transcripts'
include { BED_MEDIAN_LENGTH } from './modules/bed_median_length'
include { DEEPTOOLS_COMPUTEMATRIX_SCALEREGIONS } from './modules/deeptools_computematrix_scaleregions'
include { DEEPTOOLS_PLOTHEATMAP_MATRIX } from './modules/deeptools_plotheatmap_matrix'

workflow {

    main:

    tracks = channel.fromPath(params.gc5base_tracks)
        .splitCsv(header: true)
        .map { row -> record(name: row.name, bigwig: file(row.bigwig), gtf: file(row.gtf)) }

    // Regions are the unique NM transcripts; the median is taken over them
    nm_transcripts = GTF_UNIQUE_NM_TRANSCRIPTS(tracks)

    // Rounded to the largest bin size, so -m is divisible by every --binSize
    median_files = BED_MEDIAN_LENGTH(nm_transcripts, params.matrix_bin_sizes.max())

    tracks_with_median = median_files
        .map { t -> record(name: t.name, bigwig: t.bigwig, bed: t.bed, median: t.median.text.trim() as Integer) }

    // The `shared` body length uses one genome's median for every genome
    shared_median = tracks_with_median
        .filter { t -> t.name == params.matrix_shared_median_genome }
        .map { t -> t.median }

    bin_sizes = channel.fromList(params.matrix_bin_sizes)
    body_lengths = channel.fromList(params.matrix_body_lengths)

    // One computeMatrix run per genome x bin size x body length; the
    // computeMatrix options for each are set by ext.args in nextflow.config
    matrix_sweeps = tracks_with_median
        .combine(shared_median)
        .combine(bin_sizes)
        .combine(body_lengths)
        .map { t, shared, bin_size, body_length ->
            record(
                name: "${t.name}.bin${bin_size}.m_${body_length}",
                genome: t.name,
                bigwig: t.bigwig,
                bed: t.bed,
                bin_size: bin_size,
                body_length: body_length,
                species_median: t.median,
                shared_median: shared
            )
        }

    sweep_matrices = DEEPTOOLS_COMPUTEMATRIX_SCALEREGIONS(matrix_sweeps)

    sweep_heatmaps = DEEPTOOLS_PLOTHEATMAP_MATRIX(sweep_matrices)

    publish:

    regions = nm_transcripts
    medians = median_files
    matrices = sweep_matrices
    heatmaps = sweep_heatmaps
}

output {
    regions {
        path 'compute_matrix'
    }
    medians {
        path 'compute_matrix'
    }
    matrices {
        path 'compute_matrix'
    }
    heatmaps {
        path 'compute_matrix'
        mode 'copy'
    }
}
