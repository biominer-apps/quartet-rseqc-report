task qualimapBAMqc {
	File bam
	String bamname = basename(bam, ".bam")

	command <<<
		set -o pipefail
		set -e
		nt=$(nproc)
		qualimap bamqc -bam ${bam} -outformat PDF:HTML -nt $nt -outdir ${bamname} --java-mem-size=32G 
		tar -zcvf ${bamname}_bamqc_qualimap.tar.gz ${bamname}
	>>>

	runtime {

	}

	output {
		File bamqc_gz = "${bamname}_bamqc_qualimap.tar.gz"
	}
}
