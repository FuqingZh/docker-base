# Trait Association CLI Runtime

`platform/trait-association-cli` is the runtime toolchain image for the
`trait_association` workflow. It extends `platform/core-runtime-lo`, so it
inherits Python/R runtime basics plus LibreOffice/UNO for report export.

The image adds the command-line tools used by the active trait association
pipeline:

- sequencing and read QC: `fastp`, `fastqc`, `multiqc`, `bwa-mem2`, `samtools`,
  `gatk`
- variant and genotype processing: `bcftools`, `htslib`, `bedtools`,
  `vcftools`, `plink2`
- population and association analysis: `gcta`, `admixture`
- functional annotation: `gffread`, `eggnog-mapper`
- utilities: `pigz`

The toolchain is exposed at `/opt/trait-association-cli`. The image prepends
`/opt/trait-association-cli/bin` to `PATH`, so downstream images can call tools
directly without `micromamba activate`.

Downstream application images that need their own Python environment should
prepend it ahead of this toolchain, for example:

```Dockerfile
ENV PATH=/app/.venv/bin:/opt/trait-association-cli/bin:${PATH}
```

## Build

Build with a prebuilt micromamba environment as a BuildKit named context:

```bash
make trait-association-cli-build \
  REGISTRY=192.168.30.202:23099 \
  TA_CLI_BASE_TAG=debian-py3.14-r4.5-lo25.2-20260529 \
  TA_CLI_TAG=debian-py3.14-r4.5-lo25.2-20260529 \
  TA_CLI_ENV_CONTEXT=/home/fqzhang/micromamba/envs/gwas-cli
```

Push:

```bash
make trait-association-cli-push \
  REGISTRY=192.168.30.202:23099 \
  TA_CLI_TAG=debian-py3.14-r4.5-lo25.2-20260529
```

The environment context is not committed to this repository. It remains an
external build input until the toolchain is migrated to a lock-driven
micromamba build.
