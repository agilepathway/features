
# kubelogin (kubelogin)

Installs [kubelogin](https://github.com/Azure/kubelogin), providing azure authentication features that are not available in kubectl

## Example Usage

```json
"features": {
    "ghcr.io/agilepathway/features/kubelogin:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select or enter a version. | string | latest |

## OS Support

This Feature should work on recent `x86_64`/`amd64` or `aarch64`/`arm64` versions of Debian/Ubuntu-based distributions with the `apt` package manager installed.

`bash` is required to execute the `install.sh` script.



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/agilepathway/features/blob/main/src/kubelogin/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
