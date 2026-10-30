nextflow.enable.types = true

record SortedBamRecord {
    name: String
    bam: Path
}

process SAMTOOLS_INDEX {
    label 'process_single'
    container 'ghcr.io/bu-cds-bf528/samtools:latest'

    input:
    sample: SortedBamRecord

    output:
    record(name: sample.name, bam: sample.bam, bai: file("${sample.bam.name}.bai"))

    script:
    """
    samtools index $sample.bam
    """

    stub:
    """
    touch ${sample.bam.name}.bai
    """
}
