task stringtie {
    File bam
    File gtf
    String sample_id=basename(bam, ".sorted.bam")
    Int minimum_length_allowed_for_the_predicted_transcripts
    Int Junctions_no_spliced_reads
    Float minimum_isoform_abundance
    Float maximum_fraction_of_muliplelocationmapped_reads

    command <<<
        nt=$(nproc)
        mkdir ballgown
        stringtie -e -B -p $nt -f ${minimum_isoform_abundance} -m ${minimum_length_allowed_for_the_predicted_transcripts} -a ${Junctions_no_spliced_reads} -M ${maximum_fraction_of_muliplelocationmapped_reads} -G ${gtf} -o ballgown/${sample_id}/${sample_id}.gtf -C ${sample_id}.cov.ref.gtf -A ${sample_id}.gene.abundance.txt ${bam}
    >>>
    
    runtime {

    }
    
    output {
        File covered_transcripts = "${sample_id}.cov.ref.gtf"
        File gene_abundance = "${sample_id}.gene.abundance.txt"
        Array[File] ballgown = ["ballgown/${sample_id}/${sample_id}.gtf", "ballgown/${sample_id}/e2t.ctab", "ballgown/${sample_id}/e_data.ctab", "ballgown/${sample_id}/i2t.ctab", "ballgown/${sample_id}/i_data.ctab", "ballgown/${sample_id}/t_data.ctab"]
    }
}
