# -*- Mode: makefile-gmake; tab-width: 4; indent-tabs-mode: t -*-
#
# This file is part of the LibreOffice project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

gb_UnoApiHeadersTarget_select_variant = $(if $(filter udkapi,$(1)),comprehensive,$(2))

include $(GBUILDDIR)/platform/unxgcc.mk

# don't sort; later can override previous settings!
gb_EMSCRIPTEN_PRE_JS_FILES = \
    $(SRCDIR)/static/emscripten/environment.js \
    $(call gb_CustomTarget_get_workdir,static/emscripten_fs_image)/soffice.data.js.link \
    $(call gb_CustomTarget_get_workdir,static/emscripten_fs_image)/soffice_fonts.data.js.link \
    $(SRCDIR)/static/emscripten/soffice_fccache_loader.js \

gb_RUN_CONFIGURE := $(SRCDIR)/solenv/bin/run-configure
# avoid -s SAFE_HEAP=1 - c.f. gh#8584 this breaks source maps
gb_EMSCRIPTEN_CPPFLAGS := -pthread -s USE_PTHREADS=1 -D_LARGEFILE64_SOURCE -D_LARGEFILE_SOURCE -mbulk-memory -msimd128 -msse4.2 -msse4.1 -mssse3 -msse3 -msse2 -msse
gb_EMSCRIPTEN_LDFLAGS := $(gb_EMSCRIPTEN_CPPFLAGS)

# Initial memory size and worker thread pool
#gb_EMSCRIPTEN_LDFLAGS += -s INITIAL_MEMORY=2GB
gb_LinkTarget_LDFLAGS += -s INITIAL_MEMORY=512MB -s ALLOW_MEMORY_GROWTH=1 \
                         -s FORCE_FILESYSTEM=1 -s EXPORT_ES6=1 -s MODULARIZE=1 \
                         -lembind

# To keep the link time (and memory) down, prevent all rewriting options from wasm-emscripten-finalize
# See emscripten.py, finalize_wasm, modify_wasm = True
# So we need WASM_BIGINT=1 and ASSERTIONS=1 (2 implies STACK_OVERFLOW_CHECK)
gb_EMSCRIPTEN_LDFLAGS += -lembind -s FORCE_FILESYSTEM=1 -s WASM_BIGINT=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1 -s FETCH=1 -s ASSERTIONS=1 -s EXIT_RUNTIME=0 -s EXPORTED_RUNTIME_METHODS=["FS","cwrap","ccall","UTF16ToString","stringToUTF16","UTF8ToString","err"$(if $(ENABLE_DBGUTIL),$(COMMA)"addOnPostRun"),"registerType","throwBindingError"]
# embind runtime: required for emscripten::val / _emval_* symbols
gb_EMSCRIPTEN_QTDEFS := -DQT_NO_LINKED_LIST -DQT_NO_JAVA_STYLE_ITERATORS -DQT_NO_EXCEPTIONS -DQT_NO_DEBUG -DQT_WIDGETS_LIB -DQT_GUI_LIB -DQT_CORE_LIB

# gb_EMSCRIPTEN_LDFLAGS += -s MINIMAL_RUNTIME=1
# gb_EMSCRIPTEN_LDFLAGS += -s MINIMAL_RUNTIME_STREAMING_WASM_INSTANTIATION=1

gb_Executable_EXT := .mjs
ifeq ($(ENABLE_WASM_EXCEPTIONS),TRUE)
# Note that to really use WASM exceptions everywhere, you most probably want to also use
# CC=emcc -pthread -s USE_PTHREADS=1 -fwasm-exceptions -s SUPPORT_LONGJMP=wasm
# and CXX=em++ -pthread -s USE_PTHREADS=1 -fwasm-exceptions -s SUPPORT_LONGJMP=wasm
# in your autogen.input. Otherwise these flags won't propagate to all external libraries, I fear.
gb_EMSCRIPTEN_EXCEPT = -fwasm-exceptions -s SUPPORT_LONGJMP=wasm
gb_EMSCRIPTEN_CPPFLAGS += -fwasm-exceptions -s SUPPORT_LONGJMP=wasm
else
gb_EMSCRIPTEN_EXCEPT = -s DISABLE_EXCEPTION_CATCHING=0
endif

gb_CXXFLAGS += $(gb_EMSCRIPTEN_CPPFLAGS)

ifeq ($(ENABLE_WASM_EXCEPTIONS),TRUE)
# Here we don't use += because gb_LinkTarget_EXCEPTIONFLAGS from com_GCC_defs.mk contains -fexceptions and
# gb_EMSCRIPTEN_EXCEPT already has -fwasm-exceptions
gb_LinkTarget_EXCEPTIONFLAGS = $(gb_EMSCRIPTEN_EXCEPT)
else
gb_LinkTarget_EXCEPTIONFLAGS += $(gb_EMSCRIPTEN_EXCEPT)
endif

gb_LinkTarget_CFLAGS += $(gb_EMSCRIPTEN_CPPFLAGS) -Wno-c99-compat 
gb_LinkTarget_CXXFLAGS += $(gb_EMSCRIPTEN_CPPFLAGS) $(gb_EMSCRIPTEN_EXCEPT)

ifeq ($(ENABLE_QT5),TRUE)
gb_LinkTarget_CFLAGS += $(gb_EMSCRIPTEN_QTDEFS)
gb_LinkTarget_CXXFLAGS += $(gb_EMSCRIPTEN_QTDEFS)
endif

# Linking is really expensive, so split based on prod/dev/debug modes
# Prod (default) mode
ifeq ($(ENABLE_OPTIMIZED),TRUE)
gb_CXXFLAGS += -O3 --profiling -g2
gb_LinkTarget_CXXFLAGS += -O3 --profiling -g2
gb_LinkTarget_LDFLAGS += -s PTHREAD_POOL_SIZE=3 -O3 -s BINARYEN_EXTRA_PASSES=-O4 --profiling -g2
else
# Dev mode
ifeq ($(ENABLE_OPTIMIZED_DEBUG),TRUE)
gb_CXXFLAGS += -O3 --profiling -g2
gb_LinkTarget_CXXFLAGS += -O3 --profiling -g2
gb_LinkTarget_LDFLAGS += -s PTHREAD_POOL_SIZE=3 -s REVERSE_DEPS=all -O1 --profiling -g
else
# Debug mode
gb_CXXFLAGS += -O1 -g -gsplit-dwarf -gpubnames -gdwarf-5
gb_LinkTarget_CXXFLAGS += -O1 -g -gsplit-dwarf -gpubnames -gdwarf-5
gb_LinkTarget_LDFLAGS += -O1 -g -gsplit-dwarf -gpubnames -s PTHREAD_POOL_SIZE=1 -s REVERSE_DEPS=all -s ERROR_ON_WASM_CHANGES_AFTER_LINK
endif
endif
gb_LinkTarget_LDFLAGS += $(gb_EMSCRIPTEN_LDFLAGS) $(gb_EMSCRIPTEN_CPPFLAGS) $(gb_EMSCRIPTEN_EXCEPT)

# Linker and compiler optimize + debug flags are handled in LinkTarget.mk
gb_LINKEROPTFLAGS :=
gb_LINKERSTRIPDEBUGFLAGS :=
# This maps to g3, no source maps, but DWARF with current emscripten!
# https://developer.chrome.com/blog/wasm-debugging-2020/
gb_DEBUGINFO_FLAGS = -g

ifeq ($(HAVE_EXTERNAL_DWARF),TRUE)
gb_DEBUGINFO_FLAGS += -gseparate-dwarf
endif

gb_COMPILEROPTFLAGS := -O3

gb_COMPILERDEBUGOPTFLAGS := -O1
# No opt flags means "debug" mode
gb_COMPILERNOOPTFLAGS := -O1 -g

# cleanup addition JS and wasm files for binaries
define gb_Executable_Executable_platform
$(call gb_LinkTarget_add_auxtargets,$(2),\
        $(patsubst %.lib,%.linkdeps,$(3)) \
        $(patsubst %.lib,%.wasm,$(3)) \
        $(patsubst %.lib,%.worker.mjs,$(3)) \
        $(patsubst %.lib,%.wasm.dwp,$(3)) \
)

$(foreach pre_js,$(gb_EMSCRIPTEN_PRE_JS_FILES),$(call gb_Executable_add_prejs,$(1),$(pre_js)))

endef

define gb_CppunitTest_CppunitTest_platform
$(call gb_LinkTarget_add_auxtargets,$(2),\
        $(patsubst %.lib,%.linkdeps,$(3)) \
        $(patsubst %.lib,%.wasm,$(3)) \
        $(patsubst %.lib,%.worker.mjs,$(3)) \
        $(patsubst %.lib,%.wasm.dwp,$(3)) \
)

$(foreach pre_js,$(gb_EMSCRIPTEN_PRE_JS_FILES),$(call gb_CppunitTest_add_prejs,$(1),$(pre_js)))

endef

gb_SUPPRESS_TESTS := $(true)

define gb_Library_get_rpath
endef

define gb_Executable_get_rpath
endef

# vim: set noet sw=4 ts=4
