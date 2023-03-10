task fastq_screen {
    File read1
    File read2
    File fastq_screen_conf
    String docker
    String read1name = basename(read1,".fastq.gz")
    String read2name = basename(read2,".fastq.gz")

    command <<<
        set -o pipefail
        set -e
        nt=$(nproc)
        mkdir -p /cromwell_root/tmp
        screen_ref_dir=`dirname ${fastq_screen_conf}`
        cp -r $screen_ref_dir /cromwell_root/tmp/
        fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read1}
        fastq_screen --aligner bowtie2 --conf ${fastq_screen_conf} --top 100000 --threads $nt ${read2}
	>>>

    runtime {
        docker: docker
    }

    output {
        # File png1 = "${read1name}_screen.png"
        File txt1 = "${read1name}_screen.txt"
        File html1 = "${read1name}_screen.html"
        # File png2 = "${read2name}_screen.png"
        File txt2 = "${read2name}_screen.txt"
        File html2 = "${read2name}_screen.html"
    }
}
