task ballgown {
    File gene_abundance
    String base = basename(gene_abundance, ".gene.abundance.txt")
    Array[File] ballgown
    String docker
    String cluster
    String disk_size

    command <<<
      mkdir -p /cromwell_root/tmp/${base}
      cp -r ${sep=" " ballgown} /cromwell_root/tmp/${base}
      ballgown /cromwell_root/tmp/${base} ${base}.txt
    >>>
    
    runtime {
      docker: docker
      cluster: cluster
      systemDisk: "cloud_ssd 40"
      dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
    }
    
    output {
      File mat_expression = "${base}.txt"
    }
}