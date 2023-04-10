#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "csharp plugin latest version installed" bash -c "gauge --version | grep csharp"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults