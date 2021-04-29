# RNA Sequencing Quality Control Pipeline

> Author:  Li Zhihui
>
> E-mail：zhihuili18@fudan.edu.cn
>
> Git: http://choppy.3steps.cn/renluyao/quartet-rnaseq-qc.git
>
> Last Updates: 2020/11/25

## 安装指南

```
# 激活choppy环境
source activate choppy
# 安装app
choppy install lizhihui/quartet-rnaseq-qc
```

## App概述——中华家系1号标准物质介绍

​		建立高通量转录组测序的生物计量和质量控制关键技术体系，是保障转录组测序数据跨技术平台、跨实验室可比较、相关研究结果可重复、数据可共享的重要关键共性技术。建立国家转录组标准物质和基准数据集，突破基因组学的生物计量技术，是将测序技术转化成临床应用的重要环节与必经之路，目前国际上尚属空白。中国计量科学研究院与复旦大学、复旦大学泰州健康科学研究院共同研制了人源中华家系1号基因组标准物质（**Quartet，一套4个样本，编号分别为LCL5，LCL6，LCL7，LCL8，其中LCL5和LCL6为同卵双胞胎女儿，LCL7为父亲，LCL8为母亲**），以及相应的全基因组测序序列基准数据集（“量值”），为衡量基因序列检测准确与否提供一把“标尺”，成为保障基因测序数据可靠性的国家基准。人源中华家系1号转录组标准物质来源于泰州队列同卵双生双胞胎家庭，从遗传结构上体现了我国南北交界的人群结构特征，同时家系的设计也为“量值”的确定提供了遗传学依据。

​		中华家系1号RNA标准物质通过21个批次RNA标准物质的测序，整合集成了参考数据集，从而建立了一些依赖参考的质量控制指标。

​		在原始数据及比对数据层面，我们关注了数据量、GC含量、污染情况、比对率、比对位置分布等对测序可能会产生影响的指标，通过计算观察这些指标，我们可以一定程度上了解测序数据的质量。在测序数据表达情况层面，分别在定性和定量层面对基因检测表达水平进行了多角度的评价。通过从10个方面评估21个数据集的数据质量后我们构建了基于高置信度的已检测、未检测基因集、差异表达基因等参考数据集。通过这些指标，我们可以对新产生的测序数据进行合理的评价。

​		该Quality_control APP用于转录组测序（RNA Sequencing，RNA-Seq）数据的质量评估，包括原始数据及比对数据质控和基因表达数据质控。

## 流程与参数

![image-20200724020524943](https://tva1.sinaimg.cn/large/007S8ZIlgy1gh1g8dqs3kj30r209g40a.jpg)

### 1.原始数据质量和数据比对质量

#### [Fastqc](<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>) v0.11.5

FastQC是一个常用的测序原始数据的质控软件，主要包括12个模块，具体请参考[Fastqc模块详情](<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/Help/3%20Analysis%20Modules/>)。

```bash
fastqc -t <threads> -o <output_directory> <fastq_file>
```

#### [Fastq Screen](<https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/>) 0.12.0

Fastq Screen是检测测序原始数据中是否引⼊入其他物种，或是接头引物等污染，⽐比如，如果测序样本
是⼈人类，我们期望99%以上的reads匹配到⼈人类基因组，10%左右的reads匹配到与⼈人类基因组同源性
较⾼高的⼩小⿏鼠上。如果有过多的reads匹配到Ecoli或者Yeast，要考虑是否在培养细胞的时候细胞系被污染，或者建库时⽂文库被污染。

```bash
fastq_screen --aligner <aligner> --conf <config_file> --top <number_of_reads> --threads <threads> <fastq_file>
```

`--conf` conifg 文件主要输入了多个物种的fasta文件地址，可根据自己自己的需求下载其他物种的fasta文件加入分析

`--top`一般不需要对整个fastq文件进行检索，取前100000行

#### [Qualimap](<http://qualimap.bioinfo.cipf.es/>) 2.0.0

Qualimap是一个计算数据比对质量的软件，包含测序数据比对后的bam文件比对质量的结果。

```bash
qualimap bamqc -bam <bam_file> -outformat PDF:HTML -nt <threads> -outdir <output_directory> --java-mem-size=32G 
qualimap rnaseq -bam ${bam} -outformat HTML -outdir ${bamname}_RNAseq -gtf ${gtf} -pe --java-mem-size=10G
```

###2.数据表达质量

```
Rscript
```

分析采用实验室内部使用的代码，对从以下4个方面评估数据质量：

- Correlation of technical replicates (CTR)
- Consistency ratio of relative expression
- Correlation of relative log2FC
- Signal-to-noise Ratio (SNR) 

## App输入文件

```
#read1	#read2	#sample_id	#disk_size
```



参数设置：

若有修改需求，请在input文件中添加新的列

#### [fastp](https://github.com/OpenGene/fastp)

| 参数名                    | 参数解释                                                | 默认值                                                       |
| ------------------------- | ------------------------------------------------------- | ------------------------------------------------------------ |
| fastp_docker              | fastp软件版本信息                                       | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastp:0.19.6 |
| fastp_cluster             | fastp软件使用服务器                                     | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| trim_front1               | 修剪read1前面多少个碱基                                 | 0                                                            |
| trim_tail1                | 修剪read1尾部有多少个碱基                               | 0                                                            |
| max_len1                  | 修剪read1的尾部使其与max_len1一样长                     | 0                                                            |
| trim_front2               | 修剪read2前面多少个碱基                                 | 0                                                            |
| trim_tail2                | 修整read2尾部多少个碱基                                 | 0                                                            |
| max_len2                  | 修剪read2的尾部，使其与max_len2一样长                   | 0                                                            |
| adapter_sequence          | R1端使用接头                                            | AGATCGGAAGAGCACACGTCTGAACTCCAGTCA                            |
| adapter_sequence_r2       | R2端使用接头                                            | AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT                            |
| disable_adapter_trimming  | 是否进行接头过滤（非0则不过滤）                         | 0                                                            |
| length_required           | 接头过滤参数：短于length_required的读取将被丢弃         | 50                                                           |
| length_required1          | 接头过滤参数： 默认值20表示phred quality> = Q20是合格的 | 20                                                           |
| UMI                       | 是否使用UMI接头(非0则使用)                              | 0                                                            |
| umi_len                   | UMI接头参数：                                           | 0                                                            |
| umi_loc                   | UMI接头参数：接头位置                                   | umi_loc                                                      |
| disable_quality_filtering | 是否进行碱基质量过滤（非0则过滤）                       | 1                                                            |
| qualified_quality_phred   | 碱基质量过滤参数：允许不合格的百分比                    | 20                                                           |



#### [HISAT2](http://daehwankimlab.github.io/hisat2/)

| 参数名           | 参数解释                                                     | 默认值                                                       |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| hisat2_docker    | hisat2软件版本信息                                           | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/hisat2:v2.1.0-2 |
| hisat2_cluster   | hisat2软件使用服务器                                         | OnDemand                                                     |
| idx_prefix       | 比对文件类型                                                 | genome_snp_tran                                              |
| idx              | 比对文件地址                                                 | oss://pgx-reference-data/reference/hisat2/grch38_snp_tran/   |
| fasta            | 比对文件名称                                                 | GRCh38.d1.vd1.fa                                             |
| pen_cansplice    | 为每对规范的剪接位点（例如GT  / AG）设置惩罚                 | 0                                                            |
| pen_noncansplice | 设置每对非规范剪接位点（例如非GT  / AG）的惩罚               | 3                                                            |
| pen_intronlen    | 设置长内含子的罚分，因此与较短的内含子相比，较短的内含子优先 | G,-8,1                                                       |
| min_intronlen    | 设置最小内含子长度                                           | 30                                                           |
| max_intronlen    | 设置最大内含子长度                                           | 500000                                                       |
| maxins           | 有效的配对末端比对的最大片段长度                             | 500                                                          |
| minins           | 有效的配对末端比对的最小片段长度                             | 0                                                            |



####[Samtools](http://www.htslib.org/)

| 参数名           | 参数解释               | 默认值                                                       |
| ---------------- | ---------------------- | ------------------------------------------------------------ |
| samtools_docker  | samtools软件版本信息   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/samtools:v1.3.1 |
| samtools_cluster | samtools软件使用服务器 | OnDemand bcs.a2.large img-ubuntu-vpc,                        |
| insert_size      | 最大插入读长           | 8000                                                         |



####[StringTie](https://ccb.jhu.edu/software/stringtie/)

| 参数名                                               | 参数解释                                                     | 默认值                                                       |
| ---------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| stringtie_docker                                     | stringtie软件版本信息                                        | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/stringtie:v1.3.4 |
| stringtie_cluster                                    | stringtie软件使用服务器                                      | OnDemand bcs.a2.large img-ubuntu-vpc,                        |
| gtf                                                  | 组装gtf文件地址                                              | oss://pgx-reference-data/reference/annotation/Homo_sapiens.GRCh38.93.gtf |
| minimum_length_allowed_for_the_predicted_transcripts | 设置预测成绩单所允许的最小长度                               | 200                                                          |
| minimum_isoform_abundance                            | 将预测的转录本的最小同工型丰度设置为在给定基因座处组装的最丰富的转录本的一部分 | 0.01                                                         |
| Junctions_no_spliced_reads                           | 没有拼接的接头在两端至少与该数量的碱基对齐，这些接头被过滤掉 | 10                                                           |
| maximum_fraction_of_muliplelocationmapped_reads      | 设置允许在给定基因座处存在的多核苷酸位置映射的读数的最大分数 | 0.95                                                         |



#### [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

| 参数名                | 参数解释             | 默认值                                                       |
| --------------------- | -------------------- | ------------------------------------------------------------ |
| fastqc_cluster_config | fastqc软件使用服务器 | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| fastqc_docker         | fastqc软件版本信息   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastqc:v0.11.5 |
| fastqc_disk_size      | fastqc文件盘大小     | 150                                                          |



#### [Qualimap](http://qualimap.bioinfo.cipf.es/)

| 参数名                        | 参数解释                     | 默认值                                                       |
| ----------------------------- | ---------------------------- | ------------------------------------------------------------ |
| qualimapBAMqc_docker          | qualimapBAMqc软件版本信息    | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/qualimap:2.0.0 |
| qualimapBAMqc_cluster_config  | qualimapBAMqc软件使用服务器  | OnDemand bcs.a2.7xlarge img-ubuntu-vpc                       |
| qualimapBAMqc_disk_size       | qualimapBAMqc软件版本信息    | 500                                                          |
| qualimapRNAseq_docker         | qualimapRNAseq软件版本信息   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/qualimap:2.0.0 |
| qualimapRNAseq_cluster_config | qualimapRNAseq软件使用服务器 | OnDemand bcs.a2.7xlarge img-ubuntu-vpc                       |
| qualimapRNAseq_disk_size      | qualimapRNAseq软件版本信息   | 500                                                          |



#### [FastQ Screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)

| 参数名                     | 参数解释                    | 默认值                                                       |
| -------------------------- | --------------------------- | ------------------------------------------------------------ |
| fastqscreen_docker         | fastqscreen软件版本信息     | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/fastqscreen:0.12.0 |
| fastqscreen_cluster_config | fastqscreen软件使用服务器   | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| screen_ref_dir             | fastqscreen软件序列地址     | oss://pgx-reference-data/fastq_screen_reference/             |
| fastq_screen_conf          | fastqscreen软件序列索引地址 | oss://pgx-reference-data/fastq_screen_reference/fastq_screen.conf |
| fastqscreen_disk_size      | fastqscreen文件盘大小       | 200                                                          |
| ref_dir                    | fastqscreen序列索引地址     | oss://chinese-quartet/quartet-storage-data/reference_data/   |



#### [MultiQC](https://multiqc.info/)

| 参数名                 | 参数解释              | 默认值                                                       |
| ---------------------- | --------------------- | ------------------------------------------------------------ |
| multiqc_cluster_config | multiqc软件版本信息   | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/count:v1.0 |
| multiqc_docker         | multiqc软件使用服务器 | registry-vpc.cn-shanghai.aliyuncs.com/pgx-docker-registry/multiqc:v1.8 |
| multiqc_disk_size      | multiqc文件盘大小     | 100                                                          |



#### [Count](https://ccb.jhu.edu/software/stringtie/dl/prepDE.py)

| 参数名        | 参数解释          | 默认值                                                       |
| ------------- | ----------------- | ------------------------------------------------------------ |
| count_docker  | count版本信息     | registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/pgx-ballgown:0.0.1 |
| count_cluster | count使用服务器   | OnDemand bcs.a2.large img-ubuntu-vpc                         |
| count_length  | multiqc文件盘大小 | 150                                                          |



#### [FPKM](http://bioconductor.org/packages/release/bioc/html/ballgown.html)

| 参数名           | 参数解释               | 默认值                                                       |
| ---------------- | ---------------------- | ------------------------------------------------------------ |
| ballgown_docker  | ballgown软件版本信息   | OnDemand bcs.b2.3xlarge img-ubuntu-vpc                       |
| ballgown_cluster | ballgown软件使用服务器 | registry-vpc.cn-shanghai.aliyuncs.com/pgx-docker-registry/multiqc:v1.8 |



## App输出文件

#### 1. results_upstream_total.csv

| library | date     | sample | replicate | Total.Sequences | GC_beforemapping | total_deduplicated_percentage | Human.percentage | ERCC.percentage | EColi.percentage | Adapter.percentage | Vector.percentage | rRNA.percentage | Virus.percentage | Yeast.percentage | Mitoch.percentage | Phix.percentage | No.hits.percentage | percentage_aligned_beforemapping | error_rate | bias_53 | GC_aftermapping | percent_duplicates | sequence_length | median_insert_size | mean_coverage | ins_size_median | ins_size_peak | exonic | intronic | intergenic |
| ------- | -------- | ------ | --------- | --------------- | ---------------- | ----------------------------- | ---------------- | --------------- | ---------------- | ------------------ | ----------------- | --------------- | ---------------- | ---------------- | ----------------- | --------------- | ------------------ | -------------------------------- | ---------- | ------- | --------------- | ------------------ | --------------- | ------------------ | ------------- | --------------- | ------------- | ------ | -------- | ---------- |
| D5_1    | 20200724 | D5     | 1         | 48872858        | 52               | 45.2953551                    | 94.79            | 0               | 0                | 0.01               | 0.15              | 17.01           | 1.23             | 4.54             | 0.61              | 0               | 0.9                | 98.6435612                       | 0.01       | 1.01    | 58.0426004      | 54.7046449         | 150             | 263                | 15.8021       | 258             | 192           | 52.05  | 41.37    | 6.58       |
|         |          |        |           |                 |                  |                               |                  |                 |                  |                    |                   |                 |                  |                  |                   |                 |                    |                                  |            |         |                 |                    |                 |                    |               |                 |               |        |          |            |
|         |          |        |           |                 |                  |                               |                  |                 |                  |                    |                   |                 |                  |                  |                   |                 |                    |                                  |            |         |                 |                    |                 |                    |               |                 |               |        |          |            |

原始数据质量和数据比对质量结果汇总（example）

### 2. Depend on study design.csv

| Quality metrics              | Category    | Value         | Historical value | Rank |
| ---------------------------- | ----------- | ------------- | ---------------- | ---- |
|                              |             |               | (mean ± SD)      |      |
| ­Signal-to-Noise Ratio (SNR) | More groups | 14.45 ± 9.58  |                  |      |
| Relative correlation         | Two groups  | 0.493 ± 0.111 |                  |      |
| Absolute correlation         | One group   |               | 0.973 ± 0.015    |      |



## 结果解读

### 1.原始数据质量和数据比对质量

| 质控参数                         | 软件         | 定义                         | 参考值    |
| -------------------------------- | ------------ | ---------------------------- | --------- |
| Total.Sequences                  | Fastqc       | 总读段数量                   | > 10 M    |
| GC_beforemapping                 | Fastqc       | 比对前GC含量                 | 40% - 60% |
| total_deduplicated_percentage    | Fastqc       | 重复序列比例                 |           |
| Human.percentage                 | FastQ Screen | 比对到人基因组读段比例       | > 90 %    |
| ERCC.percentage                  | FastQ Screen | 比对到ERCC基因组读段比例     | < 5%      |
| EColi.percentage                 | FastQ Screen | 比对到大肠杆菌基因组读段比例 | < 5%      |
| Adapter.percentage               | FastQ Screen | 比对到接头读段比例           | < 5%      |
| Vector.percentage                | FastQ Screen | 比对到载体读段比例           | < 5%      |
| rRNA.percentage                  | FastQ Screen | 比对到接头读段比例           | < 10%     |
| Virus.percentage                 | FastQ Screen | 比对到rRNA读段比例           | < 5%      |
| Yeast.percentage                 | FastQ Screen | 比对到真菌读段比例           | < 5%      |
| Mitoch.percentage                | FastQ Screen | 比对到线粒体读段比例         | < 5%      |
| Phix.percentage                  | FastQ Screen | 比对到Phix读段比例           | < 5%      |
| No.hits.percentage               | FastQ Screen | 未比对到已知物种读段比例     | < 5%      |
| percentage_aligned_beforemapping | Qualimap     | 比对率                       | > 90%     |
| error_rate                       | Qualimap     | 错误率                       | < 5%      |
| bias_53                          | Qualimap     | 5-3偏好性                    |           |
| GC_aftermapping                  | Qualimap     | 比对后GC含量                 | 40% - 60% |
| percent_duplicates               | Qualimap     | 读段比对后重复比例           |           |
| sequence_length                  | Qualimap     | 读段长度                     | ~150      |
| median_insert_size               | Qualimap     | 插入读段长度                 | 200 - 300 |
| mean_coverage                    | Qualimap     | 覆盖率                       |           |
| ins_size_median                  | Qualimap     | 插入读段长度中位数           | 200 - 300 |
| ins_size_peak                    | Qualimap     | 插入读段长度众数             | 200 - 300 |
| exonic                           | Qualimap     | 比对到外显子的碱基比例       | 40% - 60% |
| intronic                         | Qualimap     | 比对到内含子的碱基比例       | 40% - 60% |
| intergenic                       | Qualimap     | 比对到内基因间区的碱基比例   | < 10%     |



###2.数据表达质量

| Quality metrics                           | Category    | Description                                                  | Reference value |
| ----------------------------------------- | ----------- | ------------------------------------------------------------ | --------------- |
| Signal-to-noise Ratio (SNR)               | More groups | Signal is defined as the average distance  between libraries from the different samples on PCA plots and noise are those  form the same samples. SNR is used to assess the ability to distinguish  technical replicates from different biological samples. | [5, inf)        |
| Consistency  ratio of relative expression | Two groups  | Proportion of genes that falls into  reference range (mean ± 2 fold SD) in relative ratio (log2FC). | [0.82, 1]       |
| Correlation of  relative log2FC           | Two groups  | Pearson correlation between mean value  of reference relative ratio and test site. | [0.96,1]        |
| Correlation of technical replicates (CTR) | One group   | CTR is calculated based on the correlation  of one sample expression level from different replicates. | [0.95, 1]       |
