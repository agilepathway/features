
# prism (prism)

Installs [Prism](https://stoplight.io/open-source/prism), an HTTP mock and proxy server powered by OpenAPI specs

## Example Usage

```json
"features": {
    "ghcr.io/agilepathway/features/prism:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a version. | string | latest |

## OS Support

This Feature should work on recent `x86_64`/`amd64` or `aarch64`/`arm64` versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

If `aarch64`/`arm64` then the Feature will install node and npm if they are not already on the devcontainer (as they are needed
for `aarch64`/`arm64` Prism installs).

`bash` is required to execute the `install.sh` script.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/agilepathway/features/blob/main/src/prism/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
