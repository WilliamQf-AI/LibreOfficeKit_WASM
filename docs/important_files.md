# Important files

## `libreoffice-core` 

The LibreOffice core from which LOK is built

`solenv/gbuild/platform/EMSCRIPTEN_INTEL_GCC.mk` - where the compile flags are set for emscripten

`solenv/desktop/Library_sofficeapp.mk` - where LibreOfficeKit's files are registered for `sofficeapp.a`

`solenv/desktop/Executable_soffice_bin.mk` - the "main" entry for `sofficeapp.js/wasm`
