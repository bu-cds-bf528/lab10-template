nextflow.enable.types = true

record RegionsRecord {
    name: String
    bigwig: Path
    bed: Path
}

process BED_MEDIAN_LENGTH {
    label 'process_single'
    conda "${projectDir}/envs/deeptools_env.yml"
    container 'ghcr.io/bu-cds-bf528/deeptools:latest'

    input:
    regions: RegionsRecord
    round_to: Integer

    output:
    record(name: regions.name, bigwig: regions.bigwig, bed: regions.bed, median: file("${regions.name}.median_gene_length.txt"))

    script:
    """
    bed_median_length.py -i $regions.bed -r $round_to > ${regions.name}.median_gene_length.txt
    """

    stub:
    """
    echo $round_to > ${regions.name}.median_gene_length.txt
    """
}
