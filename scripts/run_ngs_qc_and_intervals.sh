#!/usr/bin/env bash

# Stop if a command fails, a variable is undefined, or a pipeline fails.
set -euo pipefail

# Find the project folder relative to this script.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Create the output folders.
mkdir -p results/qc_results
mkdir -p results/bam_processed
mkdir -p results/bed_analysis

# Run quality control on the FASTQ file.
echo "Running FastQC..."
fastqc data/sample_R1.fastq.gz --outdir results/qc_results

# Sort the BAM file by genomic coordinate.
echo "Sorting and indexing the BAM..."
samtools sort \
  -o results/bam_processed/input.sorted.bam \
  data/input.bam

# Create an index for the sorted BAM.
samtools index results/bam_processed/input.sorted.bam

# Keep mapped reads with mapping quality of at least 30.
echo "Filtering mapped reads..."
samtools view -b -F 4 -q 30 \
  -o results/bam_processed/input.q30.bam \
  results/bam_processed/input.sorted.bam

# Save statistics for both the original and filtered BAM.
{
  echo "Original BAM"
  samtools flagstat data/input.bam
  echo
  echo "Filtered BAM: mapped reads with MAPQ >= 30"
  samtools flagstat results/bam_processed/input.q30.bam
} > results/bam_processed/alignment_stats.txt

# Convert the filtered alignments into BED intervals.
echo "Converting alignments to BED..."
bedtools bamtobed \
  -i results/bam_processed/input.q30.bam \
  > results/bed_analysis/alignments.bed

# Keep each alignment once if it overlaps any target exon.
echo "Finding reads overlapping target exons..."
bedtools intersect \
  -a results/bed_analysis/alignments.bed \
  -b data/exons.bed \
  -u \
  > results/bed_analysis/on_target_reads.bed

# Count the retained alignment records.
on_target_count=$(wc -l < results/bed_analysis/on_target_reads.bed)
echo "On-target reads: $on_target_count" \
  > results/bed_analysis/on_target_count.txt

echo "Pipeline completed."
cat results/bed_analysis/on_target_count.txt
