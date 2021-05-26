task count {
    File gene_abundance
    Array[File] ballgown
    String sample_id=basename(gene_abundance, ".gene.abundance.txt")
    String docker
    String cluster
    String disk_size
    Int count_length

    command <<<
      mkdir -p /cromwell_root/tmp/ballgown/${sample_id}
      cp -r ${sep=" " ballgown} /cromwell_root/tmp/ballgown/${sample_id}
      count -i /cromwell_root/tmp/ballgown -l ${count_length} -g ${sample_id}_gene_count_matrix.csv -t ${sample_id}_transcript_count_matrix.csv
      sed -i '1s/gene_id/GENE_ID/g' ${sample_id}_gene_count_matrix.csv
    >>>
    
    runtime {
      docker: docker
      cluster: cluster
      systemDisk: "cloud_ssd 40"
      dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
    }
    
    output {
      File mat_expression_genecount = "${sample_id}_gene_count_matrix.csv"
      File mat_expression_transcriptcount = "${sample_id}_transcript_count_matrix.csv"
    }
}
