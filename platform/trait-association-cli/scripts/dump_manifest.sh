#!/usr/bin/env bash
set -euo pipefail

echo "=== base libreoffice runtime manifest ==="
if [[ -f /opt/runtime_lo_manifest.txt ]]; then
  cat /opt/runtime_lo_manifest.txt
fi
echo

echo "=== trait association cli ==="
echo "TRAIT_ASSOCIATION_CLI_HOME=${TRAIT_ASSOCIATION_CLI_HOME:-/opt/trait-association-cli}"
echo "PATH=${PATH}"
echo

echo "=== tool versions ==="
plink2 --version || true
bcftools --version | head -2 || true
samtools --version | head -2 || true
fastp --version || true
fastqc --version || true
multiqc --version || true
bwa-mem2 version || true
gatk --version || true
gffread --version || true
emapper.py --version || true
bedtools --version || true
vcftools --version || true
pigz --version || true
echo

echo "=== key executables ==="
for exe in \
  plink2 \
  bcftools \
  samtools \
  fastp \
  fastqc \
  multiqc \
  bwa-mem2 \
  gatk \
  gffread \
  emapper.py \
  gcta \
  admixture \
  bedtools \
  vcftools \
  pigz
do
  printf '%s\t%s\n' "${exe}" "$(command -v "${exe}" || true)"
done
