task fastqc {
	File read1
	File read2
	String bamname1 = basename(read1,"\\.(fastq|fq)\\.gz$")
	String bamname2 = basename(read2,"\\.(fastq|fq)\\.gz$")
	String docker
	String cluster_config
	String disk_size

	command <<<
		set -o pipefail
		set -e
		nt=$(nproc)
		fastqc -t $nt -o ./ ${read1}
		fastqc -t $nt -o ./ ${read2}
		tar -zcvf ${bamname1}_fastqc.zip ${bamname1}_fastqc
		tar -zcvf ${bamname2}_fastqc.zip ${bamname2}_fastqc
	>>>

	runtime {
		docker:docker
    	cluster: cluster_config
    	systemDisk: "cloud_ssd 40"
    	dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
	}
	output {
		Array[File] fastqc1 = glob("${bamname1}_fastqc/*")
		Array[File] fastqc2 = glob("${bamname2}_fastqc/*")
		File read1_html = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read1_zip = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
		File read2_html = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read2_zip = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
	}
}