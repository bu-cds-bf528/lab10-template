nextflow.enable.types = true

record MatrixSweepRecord {
    name: String
    genome: String
    bigwig: Path
    bed: Path
    bin_size: Integer
    body_length: String
    species_median: Integer
    shared_median: Integer
}

process DEEPTOOLS_COMPUTEMATRIX_SCALEREGIONS {
    label 'process_medium'
    conda "${projectDir}/envs/deeptools_env.yml"
    container 'ghcr.io/bu-cds-bf528/deeptools:latest'

    input:
    sweep: MatrixSweepRecord

    output:
    record(name: sweep.name, matrix: file("${sweep.name}.matrix.gz"))

    script:
    // --binSize, --regionBodyLength and flanks for each sweep are set in nextflow.config
    def args = task.ext.args ?: ''
    """
    computeMatrix scale-regions \\
        -S $sweep.bigwig \\
        -R $sweep.bed \\
        -p $task.cpus \\
        -o ${sweep.name}.matrix.gz \\
        $args
    """

    stub:
    """
    touch ${sweep.name}.matrix.gz
    """
}
