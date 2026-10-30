nextflow.enable.types = true

record CoverageBamRecord {
    name: String
    variant: String
    bam: Path
    bai: Path
}

process DEEPTOOLS_BAMCOVERAGE {
    label 'process_medium'
    container 'ghcr.io/bu-cds-bf528/deeptools:latest'

    input:
    sample: CoverageBamRecord

    output:
    bigwig: Path = file("${sample.name}.${sample.variant}.bw")

    script:
    // Scaling/normalization options for each variant are set in nextflow.config
    def args = task.ext.args ?: ''
    """
    bamCoverage -b $sample.bam -o ${sample.name}.${sample.variant}.bw -p $task.cpus $args
    """

    stub:
    """
    touch ${sample.name}.${sample.variant}.bw
    """
}
