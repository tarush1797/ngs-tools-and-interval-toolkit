# NGS Tools and Interval Toolkit

Week 6 practical project using FastQC, SAMtools and BEDtools.

## Purpose

This Bash pipeline runs quality control, sorts and indexes a BAM file,
filters mapped reads by mapping quality, and identifies alignments that
overlap target exon regions.

## Requirements

- Ubuntu/Linux or WSL
- Bash
- FastQC
- SAMtools
- BEDtools

## Input data

The data folder contains small synthetic files created for this assignment:

- sample_R1.fastq.gz: 10 artificial single-end reads, each 100 bases long.
- input.sam: artificial alignments used to create the BAM file.
- input.bam: 8 mapped reads and 2 unmapped reads.
- exons.bed: 2 artificial target regions on chr1.

The BAM positions and mapping qualities were assigned for testing.
These files are not real experimental or patient data.
Despite the R1 filename, this example contains single-end reads.

## Project folders

- data/: input files
- scripts/: Bash pipeline
- results/qc_results/: FastQC HTML and ZIP reports
- results/bam_processed/: processed BAM files, index and alignment statistics
- results/bed_analysis/: alignment BED, exon overlaps and on-target count

## Run the pipeline

From the project root:

```bash
chmod +x scripts/run_ngs_qc_and_intervals.sh
./scripts/run_ngs_qc_and_intervals.sh
```

The script locates the project root automatically.
Running it again replaces the generated outputs.

## Workflow

1. Create the output directories inside results/.
2. Run FastQC on the compressed FASTQ file.
3. Sort the input BAM by coordinate and create its index.
4. Keep mapped reads with MAPQ >= 30.
5. Save flagstat statistics for the original and filtered BAM files.
6. Convert filtered alignments to BED.
7. Find alignments overlapping target exons.
8. Save the overlapping alignments and their count.

The intersection uses -u so each alignment is reported once,
even if it overlaps multiple exons.

## Verified results

| Metric | Count |
|---|---:|
| Original reads | 10 |
| Originally mapped reads | 8 |
| Originally unmapped reads | 2 |
| Mapped reads retained with MAPQ >= 30 | 6 |
| Filtered alignment BED records | 6 |
| Alignments overlapping target exons | 4 |

Filtering removed 2 unmapped reads and 2 mapped reads with MAPQ below 30.
Four of the six retained alignments overlapped target exons.

The on-target count represents alignment records. In this single-end
example, each read has one record, so it also represents individual reads.

## Limitations

This small dataset demonstrates that the commands work together.
Its FastQC results should not be interpreted as representative of a real
sequencing experiment.
