# ECMake:
`ECMake`, or `Easy CMake` is a CMake library to speed-up setting up C++ projects.

CMake is a very powerful build system, but this power is annoyingly verbose and repetitive for common project setups.

`ECMake` provides function to create executables and libraries with better defaults, going by the philosphy of opting out from norms instead of opting in, so most projects need minimal configuration while still allowing overrides when necessary.

```cmake
# The layout of the project is:
# |-- src/
# |   |-- main.cpp
# |-- CMakeLists.txt
#
# To create an executable, the CMakeLists.txt contains:
project(ProjectName LANGUAGES CXX)
add_subdirectory(".../ecmake")

# files are searched inside of the `src` dir
ec_add_executable(ExecName)
```

`ECMake` provides `ec_add_executable`, `ec_add_library` (with automatic export header generation), using a consitent API. Each binary also comes with its own version (rather than having a shared version with the project!).

`ECMake` provides `ec_add_tests`, which supports `Catch2`, `doctest` and `gtest` out of the box.

`ECMake` provides `ec_add_python_bindings`, which supports `pybind11` and `nanobind` out of the box.

# Documentation:
## `ec_add_executable`:
### Arguments:
- `OUT`: out variable of the full target name (useful when namespaces are used)
- `VERSION`: a dot separated version string
  - Default: `0.0.0.0`
  - Example: `0.2`, `1.0.0.2`
- `ROOT_DIR`: the directory in which the source code is
  - Default: `${CMAKE_CURRENT_SOURCE_DIR}/src`
- `CXX_VERSION`: the C++ standard version (`11`, `14`, `17`, `20`, ...)
  - Default: `20`
- `C_VERSION`: the C standard version
  - Default: `99`
- `INSTALL_BINDIR`: the install directory
  - Default: `${CMAKE_INSTALL_BINDIR}`
- `LINK_WITH`: libraries to link with, forwarded to `target_link_libraries`
  - If the list does not start with `PUBLIC`, `PRIVATE` or `INTERFACE`, `PRIVATE` is used
  - Example: `LINK_WITH mylib`, `LINK_WITH PUBLIC a PRIVATE b`
- `INSTALL_COMPONENT`: the install component
  - Default: `Runtime`

### Options:
- `WITH_CUDA`: add CUDA support, using `.cu` and `.cuh` files in the root directory
  - The CUDA language must already be enabled, using `project(... LANGUAGES ... CUDA)` or `enable_language(CUDA)` at file scope
- `NO_CONFIG`: do not generate a config file for the executable
- `NO_INSTALL`: do not install the executable when INSTALL is run
- `NO_PIC`: do not make the executable's code position independent
- `NO_CONFORMANT_PREPROCESSOR_MSVC`: do not use the conformant preprocessor on `MSVC`
- `NO_DEBUG_POSTFIX`: do not postfix the output name with `d` on debug
- `NO_COPY_DEPENDENCIES`: do not copy the DLLs the executable depends on next to it after building (Windows only)

## `ec_add_library`:
### Arguments:
- `OUT`: out variable of the full target name (useful when namespaces are used)
- `LIBRARY_KIND`: SHARED|STATIC or empty string, specifies the library kind
  - An empty string uses `BUILD_SHARED_LIBS` to decide the kind
  - An export header (`<name>_export.h`, defining `<NAME>_EXPORT`) is always generated. On Linux and MacOS, symbols are marked as private by default: the export macros are needed. For static libraries `<NAME>_STATIC_DEFINE` is defined, so the export macros expand to nothing and the same code builds as both kinds.
  - Default: empty string
- `VERSION`: a dot separated version string
  - Default: `0.0.0.0`
  - Example: `0.2`, `1.0.0.2`
- `ROOT_DIR`: the directory in which the source code is
  - Default: `${CMAKE_CURRENT_SOURCE_DIR}/src`
- `CXX_VERSION`: the C++ standard version (`11`, `14`, `17`, `20`, ...)
  - Default: `20`
- `C_VERSION`: the C standard version
  - Default: `99`
- `INSTALL_BINDIR`: the install directory
  - Default: `${CMAKE_INSTALL_BINDIR}`
- `LINK_WITH`: libraries to link with, forwarded to `target_link_libraries`
  - If the list does not start with `PUBLIC`, `PRIVATE` or `INTERFACE`, `PUBLIC` is used
  - Example: `LINK_WITH mylib`, `LINK_WITH PUBLIC a PRIVATE b`
- `INSTALL_COMPONENT`: the install component
  - Default: `Runtime`

### Options:
- `WITH_CUDA`: add CUDA support, using `.cu` and `.cuh` files in the root directory
  - The CUDA language must already be enabled, using `project(... LANGUAGES ... CUDA)` or `enable_language(CUDA)` at file scope
- `NO_CONFIG`: do not generate a config file for the library
- `NO_INSTALL`: do not install the library when INSTALL is run
- `NO_PIC`: do not make the library's code position independent (shared libraries are always position independent)
- `NO_CONFORMANT_PREPROCESSOR_MSVC`: do not use the conformant preprocessor on `MSVC`
- `NO_DEBUG_POSTFIX`: do not postfix the output name with `d` on debug
- `NO_COPY_DEPENDENCIES`: do not copy the DLLs the library depends on next to it after building (Windows only)

Unknown arguments are an error in all `ec_*` functions.

## Using vcpkg:
`ec_enable_vcpkg` sets the toolchain file, which is only read by the first `project()` call. As `add_subdirectory(".../ecmake")` itself calls `project()`, include `ECvcpkg.cmake` directly at the top of the top-level `CMakeLists.txt`:
```cmake
include(".../ecmake/ecmake/ECvcpkg.cmake")
ec_enable_vcpkg(".../vcpkg")
project(ProjectName LANGUAGES CXX)
add_subdirectory(".../ecmake")

ec_vcpkg_install(fmt)                       # uses VCPKG_TARGET_TRIPLET
ec_vcpkg_install(fmt LINKAGE STATIC)        # or derive a static triplet
ec_vcpkg_install(fmt TRIPLET x64-windows)   # or use an explicit triplet
```

## Options:
- `EC_SET_FETCHCONTENT_DIR`: download `FetchContent` dependencies to `<source>/.build_cache/fetch_content`
  - Default: `ON` when building ECMake itself, `OFF` when ECMake is used by another project
