include_guard(GLOBAL)

include(ECMake)
include(ECNamespace)
include(ECParseArgs)
include(GNUInstallDirs)

function(ec_add_executable NAME)
    ec_parse_with_defaults(EXEC
        "VERSION;0.0.0.0;ROOT_DIR;${CMAKE_CURRENT_SOURCE_DIR};CXX_VERSION;20;INSTALL_BINDIR;${CMAKE_INSTALL_BINDIR};INSTALL_COMPONENT;Runtime" # defaults
        "NO_CONFIG;NO_INSTALL;NO_PIC;NO_CONFORMANT_PREPROCESSOR_MSVC" # options
        "VERSION;ROOT_DIR;CXX_VERSION" # one value
        "" # multi value
        ${ARGN}
    )

    string(STRIP "${NAME}" NAME)

    ec_namespace_get(current_namespace "::")
    set(NAME_ALIAS "${current_namespace}${NAME}")
    message(VERBOSE "Creating executable ${NAME_ALIAS} v${EXEC_VERSION} with root dir `${EXEC_ROOT_DIR}`, (C++${EXEC_CXX_VERSION})...")

    ec_parse_version("${EXEC_VERSION}" EXEC_VERSION)

    file(GLOB_RECURSE _exec_cpp "${EXEC_ROOT_DIR}/src/*.cpp")
    file(GLOB_RECURSE _exec_hpp "${EXEC_ROOT_DIR}/src/*.h" "${EXEC_ROOT_DIR}/src/*.hpp")

    if(NOT EXEC_NO_CONFIG)
        message(VERBOSE "Writing `${NAME}_config.h/cpp`...")
        ec_target_write_config("${NAME_ALIAS}" "${NAME}"
            ${EXEC_VERSION_MAJOR} ${EXEC_VERSION_MINOR} ${EXEC_VERSION_PATCH} ${EXEC_VERSION_TWEAK}
            "${CMAKE_BINARY_DIR}" "" "" _exec_extra
        )
    endif()

    add_executable(${NAME} ${_exec_cpp} ${_exec_hpp} ${_exec_extra})
    add_executable(${NAME_ALIAS} ALIAS ${NAME})

    # set properties for better defaults
    ec_target_set_default_properties(${NAME} ${EXEC_CXX_VERSION}
        ${ARGN}
    )

    if(NOT EXEC_NO_INSTALL)
        # install the target
        install(TARGETS ${NAME}
            RUNTIME DESTINATION ${EXEC_INSTALL_BINDIR}
            BUNDLE DESTINATION ${EXEC_INSTALL_BINDIR}
            COMPONENT ${EXEC_INSTALL_COMPONENT}
        )
    endif()

    message(VERBOSE "Created executable ${NAME_ALIAS}.")
endfunction(ec_add_executable)
