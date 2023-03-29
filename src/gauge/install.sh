#!/usr/bin/env bash

GAUGE_VERSION="${VERSION:-"latest"}"
LANGUAGE="${LANGUAGE:-"none"}"

set -e

if [ "$(id -u)" -ne 0 ]; then
	echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
	exit 1
fi

# Clean up
rm -rf /var/lib/apt/lists/*

architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="x86_64";;
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

# make sure we have curl
check_packages ca-certificates curl

if [ "${GAUGE_VERSION}" = "latest" ]; then
    GAUGE_VERSION=$(curl -s https://api.github.com/repos/getgauge/gauge/releases/latest | grep "tag_name" | awk '{print substr($2, 3, length($2)-4)}')
	export GAUGE_VERSION
fi

github_repo_uri=https://github.com/getgauge/gauge
gauge_uri="$github_repo_uri/releases/download/v${GAUGE_VERSION}/gauge-${GAUGE_VERSION}-linux.${architecture}.zip"

gauge_install="/usr/local/lib/gauge"
zip="$gauge_install/gauge.zip"
exe="$gauge_install/gauge"

if [ ! -d "$gauge_install" ]; then
	mkdir -p "$gauge_install"
fi

check_packages unzip

curl --fail --location --progress-bar --output $zip "$gauge_uri"
unzip -d $gauge_install -o $zip
chmod +x "$exe"
rm $zip

ln -s "$exe" /usr/local/bin/gauge


if [ "${LANGUAGE}" != "none" ]; then
	su "${_REMOTE_USER}" -c "gauge install $LANGUAGE"
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
