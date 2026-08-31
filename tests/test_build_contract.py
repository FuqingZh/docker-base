"""Source checks for local/publication separation and runtime failure propagation."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class BuildContractTests(unittest.TestCase):
    def dry_run(self, *targets):
        return subprocess.check_output(
            ["make", "--no-print-directory", "-n", *targets], cwd=ROOT, text=True
        )

    def test_default_is_help(self):
        self.assertNotIn("docker build", self.dry_run())

    def test_local_builds_do_not_publish(self):
        for target in (
            "runtime-build", "build-build", "runtime-lo-build",
            "trait-association-cli-build", "signalp6-build", "mono-build",
        ):
            with self.subTest(target=target):
                command = self.dry_run(target)
                self.assertIn("docker build", command)
                self.assertNotIn("--push", command)
                self.assertNotIn("docker push", command)

    def test_mono_smoke_is_bounded_and_offline(self):
        command = self.dry_run("mono-smoke")
        for flag in ("--pull=never", "--network=none", "--cpus=4", "--memory=2g"):
            self.assertIn(flag, command)
        self.assertIn("check-mono", command)

    def test_mono_publication_is_explicit(self):
        self.assertIn("docker push", self.dry_run("mono-push"))

    def test_mono_build_defaults_match_dockerfile(self):
        command = self.dry_run("mono-build")
        dockerfile = (ROOT / "platform/mono-runtime/Dockerfile").read_text()
        for name in ("BASE_IMAGE", "MONO_VERSION"):
            default = next(
                line.removeprefix("ARG " + name + "=")
                for line in dockerfile.splitlines() if line.startswith("ARG " + name + "=")
            )
            self.assertIn("--build-arg " + name + "=" + default, command)
        self.assertIn("@sha256:", command)
        self.assertIn("APT::Update::Error-Mode=any", dockerfile)

    def test_smoke_propagates_converter_failure(self):
        # Negative control: an underlying runtime error must never become exit 0.
        with tempfile.TemporaryDirectory() as directory:
            mono = Path(directory) / "mono"
            mono.write_text("#!/bin/sh\nexit 37\n")
            mono.chmod(0o755)
            result = subprocess.run(
                ["sh", str(ROOT / "platform/mono-runtime/scripts/check-mono.sh")],
                env={**os.environ, "PATH": directory + os.pathsep + os.environ["PATH"]},
                check=False,
            )
            self.assertEqual(result.returncode, 37)
