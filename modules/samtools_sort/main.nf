nextflow.enable.types = true

record BamRecord {
    name: String
    bam: Path
}

process SAMTOOLS_SORT {
    label 'process_medium'
    container 'ghcr.io/bu-cds-bf528/samtools:latest'

    input:
    sample: BamRecord

    output:
    record(name: sample.name, bam: file("${sample.name}.sorted.bam"))

    script:
    """
    samtools sort -@ $task.cpus -o ${sample.name}.sorted.bam $sample.bam
    """

    stub:
    """
    touch ${sample.name}.sorted.bam
    """
}
