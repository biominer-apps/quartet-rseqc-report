task ballgown {
    File gene_abundance
    Array[File] ballgown
    String sample_id=basename(gene_abundance, ".gene.abundance.txt")

    command <<<
        mkdir -p /cromwell_root/tmp/${sample_id}
        cp -r ${sep=" " ballgown} /cromwell_root/tmp/${sample_id}
        ballgown /cromwell_root/tmp/${sample_id} ${sample_id}.txt
        sed -i 's/"//g' ${sample_id}.txt
        sed -i '1s/FPKM./GENE_ID\t/g' ${sample_id}.txt
    >>>
    
    runtime {
    }
    
    output {
      File mat_expression = "${sample_id}.txt"
    }
}
