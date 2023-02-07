task fastqc {
	File read1
	File read2

	command <<<
		set -o pipefail
		set -e
		nt=$(nproc)
		fastqc -t $nt -o ./ ${read1}
		fastqc -t $nt -o ./ ${read2}
	>>>

	runtime {

	}

	output {
		File read1_html = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read1_zip = sub(basename(read1), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
		File read2_html = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.html")
		File read2_zip = sub(basename(read2), "\\.(fastq|fq)\\.gz$", "_fastqc.zip")
	}
}