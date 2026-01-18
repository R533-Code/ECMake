# Copyright (c) 2026 Raphael Dib Nehme
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include(ECParseArgs)

# Enables VCPKG programmatically.
# This must be called before `project()`.
function(ec_enable_vcpkg VCPKG_REPO_DIR)
    ec_parse_with_defaults(VCPKG
        "STAMP_FILE;${CMAKE_BINARY_DIR}/.vcpkg_init"
        "" # options
        "STAMP_FILE"
        "" # multi
        ${ARGN}
    )

    get_filename_component(VCPKG_REPO_DIR "${VCPKG_REPO_DIR}" ABSOLUTE)

    if(NOT IS_DIRECTORY "${VCPKG_REPO_DIR}")
        message(FATAL_ERROR "VCPKG_REPO_DIR does not exist or is not a directory: '${VCPKG_REPO_DIR}'")
    endif()

    if(DEFINED CMAKE_TOOLCHAIN_FILE AND NOT CMAKE_TOOLCHAIN_FILE STREQUAL "")
        message(STATUS "CMAKE_TOOLCHAIN_FILE already set to: ${CMAKE_TOOLCHAIN_FILE} (ec_enable_vcpkg will not override)")
        return()
    endif()

    if(WIN32)
        set(_vcpkg_exe "${VCPKG_REPO_DIR}/vcpkg.exe")
        set(_bootstrap "${VCPKG_REPO_DIR}/bootstrap-vcpkg.bat")
    else()
        set(_vcpkg_exe "${VCPKG_REPO_DIR}/vcpkg")
        set(_bootstrap "${VCPKG_REPO_DIR}/bootstrap-vcpkg.sh")
    endif()

    if(NOT EXISTS "${_bootstrap}")
        message(FATAL_ERROR "Bootstrap script not found at: '${_bootstrap}'")
    endif()

    # If already stamped and executable exists, do nothing.
    if(EXISTS "${VCPKG_STAMP_FILE}" AND EXISTS "${_vcpkg_exe}")
        message(STATUS "vcpkg already bootstrapped (stamp exists), skipping. Stamp: ${VCPKG_STAMP_FILE}")
    else()
        message(STATUS "Bootstrapping vcpkg in '${VCPKG_REPO_DIR}'...")
        execute_process(
            COMMAND "${_bootstrap}"
            WORKING_DIRECTORY "${VCPKG_REPO_DIR}"
            COMMAND_ERROR_IS_FATAL ANY
        )

        string(TIMESTAMP _ts_utc "%Y-%m-%dT%H:%M:%SZ" UTC)
        file(WRITE "${VCPKG_STAMP_FILE}" "bootstrapped:${_ts_utc}\nrepo:${VCPKG_REPO_DIR}\n")
        message(STATUS "vcpkg bootstrapped. Stamp: ${VCPKG_STAMP_FILE}")
    endif()

    if(NOT EXISTS "${VCPKG_REPO_DIR}/scripts/buildsystems/vcpkg.cmake")
        message(FATAL_ERROR "vcpkg toolchain file not found in repo: '${VCPKG_REPO_DIR}/scripts/buildsystems/vcpkg.cmake'")
    endif()

    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_REPO_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "" FORCE)
    message(STATUS "Using vcpkg toolchain: ${CMAKE_TOOLCHAIN_FILE}")

    set(EC_VCPKG_EXECUTABLE "${_vcpkg_exe}" CACHE FILEPATH "vcpkg executable" FORCE)
endfunction()

# Install a package using vcpkg.
# Requires ec_enable_vcpkg() to have run.
# Supported calls:
#   ec_vcpkg_install(<pkg>)                          # uses VCPKG_TARGET_TRIPLET as-is
#   ec_vcpkg_install(<pkg> LINKAGE STATIC|SHARED)    # derives triplet conservatively
#   ec_vcpkg_install(<pkg> TRIPLET <triplet-name>)   # explicit triplet (recommended)
macro(ec_vcpkg_install PACKAGE)
  if(NOT DEFINED EC_VCPKG_EXECUTABLE OR EC_VCPKG_EXECUTABLE STREQUAL "")
    message(FATAL_ERROR "ec_vcpkg_install() requires EC_VCPKG_EXECUTABLE to be set. Call ec_enable_vcpkg()/ec_vcpkg_init() first.")
  endif()
  if(NOT EXISTS "${EC_VCPKG_EXECUTABLE}")
    message(FATAL_ERROR "EC_VCPKG_EXECUTABLE does not exist: '${EC_VCPKG_EXECUTABLE}'")
  endif()

  # Derive vcpkg root from executable location: <root>/vcpkg(.exe)
  get_filename_component(_ec_vcpkg_root "${EC_VCPKG_EXECUTABLE}" DIRECTORY)

  # Parse keyword args
  #   LINKAGE: STATIC|SHARED
  #   TRIPLET: <triplet>
  cmake_parse_arguments(VCPKGI "" "LINKAGE;TRIPLET" "" ${ARGN})

  if(DEFINED VCPKGI_UNPARSED_ARGUMENTS AND NOT VCPKGI_UNPARSED_ARGUMENTS STREQUAL "")
    message(FATAL_ERROR
      "ec_vcpkg_install(${PACKAGE} ...): unrecognized arguments: ${VCPKGI_UNPARSED_ARGUMENTS}\n"
      "Valid forms:\n"
      "  ec_vcpkg_install(<pkg>)\n"
      "  ec_vcpkg_install(<pkg> LINKAGE STATIC|SHARED)\n"
      "  ec_vcpkg_install(<pkg> TRIPLET <triplet-name>)"
    )
  endif()

  if(NOT VCPKGI_TRIPLET STREQUAL "" AND NOT VCPKGI_LINKAGE STREQUAL "")
    message(FATAL_ERROR "ec_vcpkg_install(${PACKAGE} ...): use TRIPLET or LINKAGE, not both.")
  endif()

  # resolve triplet file (best-effort validation that triplet exists in this checkout)
  function(_ec_resolve_triplet_file out_var vcpkg_root triplet_name)
    set(_f1 "${vcpkg_root}/triplets/${triplet_name}.cmake")
    set(_f2 "${vcpkg_root}/triplets/community/${triplet_name}.cmake")
    if(EXISTS "${_f1}")
      set(${out_var} "${_f1}" PARENT_SCOPE)
    elseif(EXISTS "${_f2}")
      set(${out_var} "${_f2}" PARENT_SCOPE)
    else()
      set(${out_var} "" PARENT_SCOPE)
    endif()
  endfunction()

  # choose triplet
  set(_triplet "")
  set(_triplet_file "")

  if(NOT VCPKGI_TRIPLET STREQUAL "")
    set(_triplet "${VCPKGI_TRIPLET}")

  else()
    if(NOT DEFINED VCPKG_TARGET_TRIPLET OR VCPKG_TARGET_TRIPLET STREQUAL "")
      message(FATAL_ERROR
        "ec_vcpkg_install(${PACKAGE} ...): TRIPLET not provided and VCPKG_TARGET_TRIPLET is not set.\n"
        "Either set VCPKG_TARGET_TRIPLET or call ec_vcpkg_install(${PACKAGE} TRIPLET <triplet-name>)."
      )
    endif()

    set(_base_triplet "${VCPKG_TARGET_TRIPLET}")

    if(VCPKGI_LINKAGE STREQUAL "")
      set(_triplet "${_base_triplet}")

    else()
      if(NOT (VCPKGI_LINKAGE STREQUAL "STATIC" OR VCPKGI_LINKAGE STREQUAL "SHARED"))
        message(FATAL_ERROR "ec_vcpkg_install(${PACKAGE} ...): LINKAGE must be STATIC or SHARED (got '${VCPKGI_LINKAGE}').")
      endif()

      if(VCPKGI_LINKAGE STREQUAL "STATIC")
        # Prefer '<base>-static' unless already static
        string(REGEX MATCH "-static$" _is_static "${_base_triplet}")
        if(_is_static)
          set(_triplet "${_base_triplet}")
        else()
          set(_triplet "${_base_triplet}-static")
        endif()

      elseif(VCPKGI_LINKAGE STREQUAL "SHARED")
        # refuse -static base triplets for SHARED
        string(REGEX MATCH "-static$" _is_static "${_base_triplet}")
        if(_is_static)
          message(FATAL_ERROR
            "ec_vcpkg_install(${PACKAGE} LINKAGE SHARED): VCPKG_TARGET_TRIPLET is a static triplet: '${_base_triplet}'.\n"
            "Set VCPKG_TARGET_TRIPLET to a non-static triplet or pass TRIPLET explicitly."
          )
        endif()
        set(_triplet "${_base_triplet}")
      endif()
    endif()
  endif()

  _ec_resolve_triplet_file(_triplet_file "${_ec_vcpkg_root}" "${_triplet}")
  if(_triplet_file STREQUAL "")
    message(FATAL_ERROR
      "ec_vcpkg_install(${PACKAGE} ...): triplet '${_triplet}' not found under:\n"
      "  '${_ec_vcpkg_root}/triplets' or '${_ec_vcpkg_root}/triplets/community'\n"
      "Provide a valid triplet name, or create an overlay/custom triplet."
    )
  endif()

  # early detection: dry-run first
  execute_process(
    COMMAND "${EC_VCPKG_EXECUTABLE}" install --dry-run "${PACKAGE}:${_triplet}"
    RESULT_VARIABLE _dry_run_result
  )
  if(NOT _dry_run_result EQUAL 0)
    message(FATAL_ERROR
      "vcpkg dry-run failed for ${PACKAGE}:${_triplet}.\n"
      "This commonly indicates the port/triplet/linkage combination is not supported (or requires custom/overlay triplets).\n"
      "Triplet file checked at: '${_triplet_file}'."
    )
  endif()

  # install
  execute_process(
    COMMAND "${EC_VCPKG_EXECUTABLE}" install "${PACKAGE}:${_triplet}"
    RESULT_VARIABLE _result
  )
  if(NOT _result EQUAL 0)
    message(FATAL_ERROR "Failed to install ${PACKAGE} with triplet ${_triplet}")
  endif()

  # expose install prefix
  set(_installed_prefix "${_ec_vcpkg_root}/installed/${_triplet}")
  string(TOUPPER "${PACKAGE}" _upper_package)
  set("EC_VCPKG_${_upper_package}_PATH" "${_installed_prefix}" CACHE PATH "vcpkg install prefix for ${PACKAGE} (${_triplet})" FORCE)

  message(STATUS "Successfully installed ${PACKAGE} with triplet ${_triplet}")
  message(STATUS "EC_VCPKG_${_upper_package}_PATH='${_installed_prefix}'")
endmacro()
