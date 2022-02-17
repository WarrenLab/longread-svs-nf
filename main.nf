nextflow.enable.dsl = 2

params.reference = ""
params.subreads = ""

process minimap {
    input:
        path(subreadsBam)
        path(reference)

    output:
        path("mapped.bam")

    """
    samtools fastq $subreadsBam \
        | minimap2 -t $task.cpus -ax map-pb $reference - \
        | samtools view -bh - \
        | samtools sort - \
        > mapped.bam
    """
}

process sniffles {
    input:
        path("mapped.bam")
        path(reference)

    output:
        path("variants.vcf")

    """
    sniffles -t $task.cpus --reference $reference \
        -m mapped.bam -v variants.vcf
    """
}

workflow {
    subreadsBam = Channel.fromPath(params.subreads)
    reference = Channel.fromPath(params.reference)

    sniffles(minimap(subreadsBam, reference), reference)
}
