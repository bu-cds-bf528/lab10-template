nextflow.enable.types = true

record SweepMatrixRecord {
    name: String
    matrix: Path
}

process DEEPTOOLS_PLOTHEATMAP_MATRIX {
    label 'process_single'
    conda "${projectDir}/envs/deeptools_env.yml"
    container 'ghcr.io/bu-cds-bf528/deeptools:latest'

    input:
    sweep: SweepMatrixRecord

    output:
    heatmap: Path = file("${sweep.name}.heatmap.png")

    script:
    def args = task.ext.args ?: ''
    """
    plotHeatmap -m $sweep.matrix \\
        -o ${sweep.name}.heatmap.png \\
        --samplesLabel "$sweep.name" \\
        $args
    """

    stub:
    """
    touch ${sweep.name}.heatmap.png
    """
}
