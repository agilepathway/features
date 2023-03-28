#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
specified_version_in_scenarios_json=1.4.2
check "verify specified version installed" bash -c "gauge --version | grep $specified_version_in_scenarios_json"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
