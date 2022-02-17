nextflow.enable.dsl = 2

params.reference = ""
params.subreads = ""

process minimap {
    input:
        path(subreadsBam)

    output:
        path("mapped.bam")

    """
    samtools fastq $subreadsBam
        | minimap2 -t $task.cpus -ax map-pb ${params.reference} - \
        | samtools view -bh - \
        | samtools sort - \
        > mapped.bam
    """
}

process sniffles {
    input:
        path("mapped.bam")

    output:
        path("variants.vcf")

    """
    sniffles -t $task.cpus --reference $params.reference \
        -m mapped.bam -v variants.vcf
    """
}

workflow {
    subreadsBam = Channel.fromPath(params.subreads)

    sniffles(minimap(subreadsBam))
}
