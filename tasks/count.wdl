task count {
    Array[File] ballgown
    String sample_id
    String docker
    String cluster
    String disk_size

    command <<<
      mkdir -p /cromwell_root/tmp/ballgown/${sample_id}
      cp -r ${sep=" " ballgown} /cromwell_root/tmp/ballgown/${sample_id}
      count -g ${sample_id}_gene_count_matrix.csv -t ${sample_id}_transcript_count_matrix.csv
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