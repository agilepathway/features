#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
specified_version_in_scenarios_json=0.3.16
check "python plugin specific version installed" bash -c "gauge --version | grep 'python ($specified_version_in_scenarios_json)'"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
