#!/bin/sh
# Propagate the runtime's exit code; assembly failures must fail the caller.
set -eu
exec mono /opt/mono-runtime/smoke.exe
