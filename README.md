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