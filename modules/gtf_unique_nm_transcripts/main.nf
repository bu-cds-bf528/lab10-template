nextflow.enable.types = true

record TrackRecord {
    name: String
    bigwig: Path
    gtf: Path
}

process GTF_UNIQUE_NM_TRANSCRIPTS {
    label 'process_single'
    conda "${projectDir}/envs/deeptools_env.yml"
    container 'ghcr.io/bu-cds-bf528/deeptools:latest'

    input:
    track: TrackRecord

    output:
    record(name: track.name, bigwig: track.bigwig, bed: file("${track.name}.nm_transcripts.bed"))

    script:
    """
    gtf_unique_nm_transcripts.py -i $track.gtf -o ${track.name}.nm_transcripts.bed
    """

    stub:
    """
    touch ${track.name}.nm_transcripts.bed
    """
}
