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
```

# Building

```bash
./scripts/build.sh
```

# Important files

`libreoffice-core/solenv/gbuild/platform/EMSCRIPTEN_INTEL_GCC.mk` - where the compile flags are set for emscripten
