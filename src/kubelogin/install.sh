#!/usr/bin/env bash

KUBELOGIN_VERSION="${VERSION:-"latest"}"

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
"Darwin x86_64") architecture="darwin-amd64" ;;
"Darwin arm64") architecture="darwin-arm64" ;;
x86_64) architecture="linux-amd64" ;;
aarch64) architecture="linux-arm64" ;;
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

github_repo_uri=https://github.com/Azure/kubelogin
if [ "${KUBELOGIN_VERSION}" == "latest" ]; then
	kubelogin_uri="$github_repo_uri/releases/latest/download/kubelogin-${architecture}.zip"
else
	kubelogin_uri="$github_repo_uri/releases/download/v${KUBELOGIN_VERSION}/kubelogin-${architecture}.zip"
fi

kubelogin_install="/usr/local/lib/kubelogin"
# the architecture dir in the zip has _ not -
bin_architecture_dir=${architecture/-/_}
bin_dir="$kubelogin_install/bin/$bin_architecture_dir"
zip="$kubelogin_install/kubelogin.zip"
exe="$bin_dir/kubelogin"

if [ ! -d "$bin_dir" ]; then
	mkdir -p "$bin_dir"
fi

check_packages unzip

curl --fail --location --progress-bar --output $zip "$kubelogin_uri"
unzip -d $kubelogin_install -o $zip
chmod +x "$exe"
rm $zip

ln -s "$exe" /usr/local/bin/kubelogin

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
