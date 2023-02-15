task hisat2 {
    File idx
    String idx_prefix
    File Trim_R1
    File Trim_R2
    String docker
    String sample_id=basename(Trim_R1, "_R1.fastq.gz")
    String pen_intronlen
    Int pen_cansplice
    Int pen_noncansplice
    Int min_intronlen
    Int max_intronlen
    Int maxins
    Int minins
   
    command <<<
        nt=$(nproc)
        hisat2 -t -p $nt -x ${idx}/${idx_prefix} --pen-cansplice ${pen_cansplice} --pen-noncansplice ${pen_noncansplice} --pen-intronlen ${pen_intronlen} --min-intronlen ${min_intronlen} --max-intronlen ${max_intronlen} --maxins ${maxins} --minins ${minins} --un-conc-gz ${sample_id}_un.fq.gz -1 ${Trim_R1} -2 ${Trim_R2} -S ${sample_id}.sam 
    >>>
   
    runtime { 
        docker: docker
    }

    output {
        File sam = "${sample_id}.sam"
        File unmapread_1p = "${sample_id}_un.fq.1.gz"
        File unmapread_2p = "${sample_id}_un.fq.2.gz"
    }
}
