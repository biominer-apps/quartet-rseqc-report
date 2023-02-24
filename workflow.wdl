import "./tasks/fastp.wdl" as fastp_task
import "./tasks/hisat2.wdl" as hisat2_task
import "./tasks/samtools.wdl" as samtools_task
import "./tasks/stringtie.wdl" as stringtie_task
import "./tasks/fastqc.wdl" as fastqc_task
import "./tasks/fastqscreen.wdl" as fastqscreen_task
import "./tasks/qualimapBAMqc.wdl" as qualimapBAMqc_task
import "./tasks/qualimapRNAseq.wdl" as qualimapRNAseq_task
import "./tasks/ballgown.wdl" as ballgown_task
import "./tasks/count.wdl" as count_task

workflow {{ project_name }} {
    # Required
    File fastq_r1_D5
    File fastq_r2_D5
    File fastq_r1_D6
    File fastq_r2_D6
    File fastq_r1_F7
    File fastq_r2_F7
    File fastq_r1_M8
    File fastq_r2_M8

    Array[File] r1_files = [fastq_r1_D5, fastq_r1_D6, fastq_r1_F7, fastq_r1_M8]
    Array[File] r2_files = [fastq_r2_D5, fastq_r2_D6, fastq_r2_F7, fastq_r2_M8]

    Array[Pair[File, File]] zipped_files = zip(r1_files, r2_files)

    File idx
    File fastq_screen_conf
    File gtf

    # Optional
    String idx_prefix
    String docker
    String adapter_sequence
    String adapter_sequence_r2
    String umi_loc
    String pen_intronlen
    Int trim_front1 
    Int trim_tail1 
    Int max_len1 
    Int trim_front2 
    Int trim_tail2  
    Int max_len2 
    Int disable_adapter_trimming
    Int length_required
    Int umi_len
    Int UMI
    Int qualified_quality_phred
    Int length_required1
    Int disable_quality_filtering
    Int pen_cansplice
    Int pen_noncansplice
    Int min_intronlen
    Int max_intronlen
    Int maxins
    Int minins
    Int insert_size
    Int minimum_length_allowed_for_the_predicted_transcripts
    Int Junctions_no_spliced_reads
    Int count_length
    Float minimum_isoform_abundance
    Float maximum_fraction_of_muliplelocationmapped_reads

    for (file_pair in zipped_files) {
        call fastp_task.fastp as fastp {
            input: 
            read1 = file_pair[0], 
            read2 = file_pair[1],
            adapter_sequence = adapter_sequence,
            adapter_sequence_r2 = adapter_sequence_r2,
            umi_loc = umi_loc,
            trim_front1 = trim_front1,
            trim_tail1 = trim_tail1, 
            max_len1  = max_len1,
            trim_front2  = trim_front2,
            trim_tail2   = trim_tail2,
            max_len2  = max_len2,
            disable_adapter_trimming = disable_adapter_trimming,
            length_required = length_required,
            umi_len = umi_len,
            UMI = UMI,
            qualified_quality_phred = qualified_quality_phred,
            length_required1 = length_required1,
            disable_quality_filtering = disable_quality_filtering,
            docker = docker
        }

        call fastqc_task.fastqc as fastqc {
            input:
            read1 = fastp.Trim_R1, 
            read2 = fastp.Trim_R2,
            docker = docker
        }

        call fastqscreen_task.fastq_screen as fastqscreen {
            input:
            read1 = fastp.Trim_R1, 
            read2 = fastp.Trim_R2,
            fastq_screen_conf = fastq_screen_conf,
            docker = docker
        }

        call hisat2_task.hisat2 as hisat2 {
            input: 
            idx = idx,
            idx_prefix = idx_prefix,
            Trim_R1 = fastp.Trim_R1, 
            Trim_R2 = fastp.Trim_R2,
            pen_intronlen = pen_intronlen,
            pen_cansplice = pen_cansplice,
            pen_noncansplice = pen_noncansplice,
            min_intronlen = min_intronlen,
            max_intronlen = max_intronlen,
            maxins = maxins,
            minins = minins,
            docker = docker
        }

        call samtools_task.samtools as samtools {
            input: 
            sam = hisat2.sam,
            insert_size = insert_size,
            docker = docker
        }
            
        call qualimapBAMqc_task.qualimapBAMqc as qualimapBAMqc {
            input:
            bam = samtools.out_percent,
            docker = docker
        }

        call qualimapRNAseq_task.qualimapRNAseq as qualimapRNAseq {
            input:
            bam = samtools.out_percent,
            gtf = gtf,
            docker = docker
        }

        call stringtie_task.stringtie as stringtie {
            input: 
            gtf = gtf, 
            bam = samtools.out_bam,
            minimum_length_allowed_for_the_predicted_transcripts = minimum_length_allowed_for_the_predicted_transcripts,
            Junctions_no_spliced_reads = Junctions_no_spliced_reads,
            minimum_isoform_abundance = minimum_isoform_abundance,
            maximum_fraction_of_muliplelocationmapped_reads = maximum_fraction_of_muliplelocationmapped_reads,
            docker = docker
        }

        call ballgown_task.ballgown as ballgown {
            input: 
            ballgown = stringtie.ballgown,
            gene_abundance = stringtie.gene_abundance,
            docker = docker
        } 

        call count_task.count as count {
            input: 
            ballgown = stringtie.ballgown,
            gene_abundance = stringtie.gene_abundance,
            count_length = count_length,
            docker = docker
        } 
    }
}
