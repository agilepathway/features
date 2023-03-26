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
x86_64) architecture="x64";;
aarch64 | armv8*) architecture="arm64";;
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

install_via_npm() {
	PACKAGE=$1
	VERSION=$2

	# install node+npm if does not exists
	if ! type npm >/dev/null 2>&1; then
		echo "Installing node and npm..."
		check_packages curl ca-certificates
		curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/node/install.sh | VERSION="lts" bash
		export NVM_DIR=/usr/local/share/nvm
		[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
		[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
	fi

	if [ "$(npm list --global --parseable --depth 0 --omit dev | grep "$PACKAGE")" != "" ]; then
		echo "$PACKAGE  already exists - skipping installation"
		exit 0
	fi

	if [ "$VERSION" = "latest" ]; then
		npm_installation="$PACKAGE"
	else
		npm_installation="${PACKAGE}@${VERSION}"
	fi

	npm install -g --omit=dev "$npm_installation"
}

if [ $architecture == "arm64" ]; then
    # there is currently no Prism arm64 binary (see https://github.com/stoplightio/prism/issues/2055),
	# so fallback is to install via npm
	install_via_npm "@stoplight/prism-cli" "$PRISM_VERSION"
else
	check_packages ca-certificates curl

	github_repo_uri=https://github.com/stoplightio/prism
	if [ "${PRISM_VERSION}" == "latest" ]; then
		prism_uri="$github_repo_uri/releases/latest/download/prism-cli-linux"
	else
		prism_uri="$github_repo_uri/releases/download/v${PRISM_VERSION}/prism-cli-linux"
	fi

	prism_install_dir="/usr/local/lib/prism"
	exe="$prism_install_dir/prism"

	if [ ! -d "$prism_install_dir" ]; then
		mkdir -p "$prism_install_dir"
	fi

	curl --fail --location --progress-bar --output "$exe" "$prism_uri"
	chmod +x "$exe"

	ln -s "$exe" /usr/local/bin/prism
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
