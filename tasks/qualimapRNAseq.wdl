task qualimapRNAseq {
    File bam
    File gtf
    String docker
    String bamname = basename(bam,".bam")

    command <<<
        set -o pipefail
        set -e
        nt=$(nproc)
        qualimap rnaseq -bam ${bam} -outformat HTML -outdir ${bamname} -gtf ${gtf} -pe --java-mem-size=10G
        tar -zcvf ${bamname}_rnaseq_qualimap.tar.gz ${bamname}
    >>>

    runtime {
        docker: docker
    }

    output {
        File rnaseq_gz = "${bamname}_rnaseq_qualimap.tar.gz"	
    }
}
