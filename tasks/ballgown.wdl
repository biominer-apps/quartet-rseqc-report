task ballgown {
    File gene_abundance
    String docker
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
      docker: docker
      # cluster: "OnDemand bcs.a2.large img-ubuntu-vpc"
      # systemDisk: "cloud_ssd 40"
      # dataDisk: "cloud_ssd 100 /cromwell_root/"
    }
    
    output {
      File mat_expression = "${sample_id}.txt"
    }
}
