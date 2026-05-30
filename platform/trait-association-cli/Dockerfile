ARG REGISTRY=192.168.30.202:23099
ARG RUNTIME_TAG=debian-py3.14-r4.5-lo25.2-20260529
FROM ${REGISTRY}/platform/core-runtime:${RUNTIME_TAG}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG http_proxy
ARG https_proxy
ARG no_proxy

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    http_proxy=${http_proxy} \
    https_proxy=${https_proxy} \
    no_proxy=${no_proxy} \
    TRAIT_ASSOCIATION_CLI_HOME=/opt/trait-association-cli \
    PATH=/opt/trait-association-cli/bin:${PATH}

WORKDIR /opt

# Copy the prebuilt micromamba environment into its original prefix first.
# Some packaged scripts and libraries can contain absolute conda-prefix paths;
# the semantic /opt path is therefore exposed as a symlink for stable public use.
COPY --from=trait_association_cli_env / /home/fqzhang/micromamba/envs/gwas-cli/

RUN set -eux; \
    ln -s /home/fqzhang/micromamba/envs/gwas-cli "${TRAIT_ASSOCIATION_CLI_HOME}"; \
    printf '%s\n' \
      'export TRAIT_ASSOCIATION_CLI_HOME=/opt/trait-association-cli' \
      'case ":${PATH}:" in' \
      '  *:/opt/trait-association-cli/bin:*) ;;' \
      '  *) export PATH=/opt/trait-association-cli/bin:${PATH} ;;' \
      'esac' \
      > /etc/profile.d/trait-association-cli.sh

COPY platform/trait-association-cli/scripts/dump_manifest.sh /usr/local/bin/dump_manifest-trait-association-cli.sh

RUN set -eux; \
    chmod +x /usr/local/bin/dump_manifest-trait-association-cli.sh; \
    /usr/local/bin/dump_manifest-trait-association-cli.sh > /opt/trait_association_cli_manifest.txt

RUN set -eux; \
    plink2 --version; \
    bcftools --version; \
    samtools --version; \
    fastp --version; \
    fastqc --version; \
    multiqc --version; \
    bwa-mem2 version; \
    gatk --version; \
    gffread --version; \
    emapper.py --version; \
    gcta --help >/tmp/gcta.help 2>&1 || test -s /tmp/gcta.help; \
    admixture --help >/tmp/admixture.help 2>&1 || test -s /tmp/admixture.help; \
    bedtools --version; \
    vcftools --version; \
    pigz --version

WORKDIR /work
CMD ["bash"]

LABEL org.opencontainers.image.description="Trait association CLI toolchain runtime, including sequencing, variant, population, association, annotation, and report export tools." \
    org.opencontainers.image.licenses="MIT"
