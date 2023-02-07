task samtools {
   File sam
   String sample_id=basename(sam, ".sam")
   String bam = sample_id + ".bam"
   String sorted_bam = sample_id + ".sorted.bam"
   String percent_bam = sample_id + ".percent.bam"
   String sorted_bam_index = sample_id + ".sorted.bam.bai"
   String ins_size = sample_id + ".ins_size"
   Int insert_size

   command <<<
        set -o pipefail
        set -e
        samtools view -bS ${sam} > ${bam}
        samtools sort -m 1000000000 ${bam} -o ${sorted_bam}
        samtools index ${sorted_bam}
        samtools view -bs 42.1 ${sorted_bam} > ${percent_bam}
        samtools stats -i ${insert_size} ${sorted_bam} |grep ^IS|cut -f 2- > ${sample_id}.ins_size
   >>>

   runtime {

   }

   output {
        File out_bam = sorted_bam
        File out_percent = percent_bam
        File out_bam_index = sorted_bam_index
        File out_ins_size = ins_size
   }
}

