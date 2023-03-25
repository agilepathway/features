#!/usr/bin/env bash

PRISM_VERSION="${VERSION:-"latest"}"

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
"Darwin x86_64" | "Darwin arm64") architecture="macos" ;;
x86_64 | aarch64) architecture="linux" ;;
*)
	echo "(!) Architecture ${architecture} unsupported"
	exit 1
	;;
esac

# Checks if packages are installed and installs them if not
check_packages() {
	if ! dpkg -s "$@" >/dev/null 2>&1; then
		if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
			echo "Running apt-get update..."
			apt-get update -y
		fi
		apt-get -y install --no-install-recommends "$@"
	fi
}

# make sure we have curl
check_packages ca-certificates curl

github_repo_uri=https://github.com/stoplightio/prism
if [ "${PRISM_VERSION}" == "latest" ]; then
	prism_uri="$github_repo_uri/releases/latest/download/prism-cli-${architecture}"
else
	prism_uri="$github_repo_uri/releases/download/v${PRISM_VERSION}/prism-cli-${architecture}"
fi

prism_install_dir="/usr/local/lib/prism"
exe="$prism_install_dir/prism"

if [ ! -d "$prism_install_dir" ]; then
	mkdir -p "$prism_install_dir"
fi

curl --fail --location --progress-bar --output "$exe" "$prism_uri"
chmod +x "$exe"

ln -s "$exe" /usr/local/bin/prism

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
