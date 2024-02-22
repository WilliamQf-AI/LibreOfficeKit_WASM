# Macro Open Source Project: LOK

This is a public project that forks LibreOffice to provide functionality and fixes that don't fit in [the upstream project](https://github.com/LibreOffice/core).

This repository is open sourced under the [Mozilla Public License 2.0](LICENSE).

This project is not a part of the official LibreOffice project, nor endorsed by the Document Foundation.

# Prerequisites

TODO: List pre-reqs for each platform

Setup the repo:
```bash
git clone https://github.com/coparse-inc/libreofficekit
./scripts/setup.sh
# if you're using VS Code or clangd in vim, run this
./scripts/prepare-clangd.sh
```

# Building

```bash
# Run configure.sh for the initial build or any configuration changes
./scripts/configure.sh
# Run build.sh for any code changes
./scripts/build.sh
```

# Docs

- [Important Files](./docs/important_files.md)
