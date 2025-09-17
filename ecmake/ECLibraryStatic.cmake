include_guard(GLOBAL)

include(ECUtil)
include(ECNamespace)
include(ECParseArgs)

function(ec_add_library_static NAME)
    # This must happen before parsing the defaults so that
    # ${CMAKE_INSTALL_BINDIR} expands to a non-empty string
    include(GNUInstallDirs)

    ec_parse_with_defaults(LIB
        "VERSION;0.0.0.0;ROOT_DIR;${CMAKE_CURRENT_SOURCE_DIR};CXX_VERSION;20;INSTALL_BINDIR;${CMAKE_INSTALL_BINDIR};INSTALL_COMPONENT;Runtime" # defaults
        "NO_CONFIG;NO_PIC;NO_INSTALL;NO_CONFORMANT_PREPROCESSOR_MSVC;NO_DEBUG_POSTFIX" # options
        "VERSION;ROOT_DIR;CXX_VERSION" # one value
        "" # multi value
        ${ARGN}
    )

    string(STRIP "${NAME}" NAME)

    ec_namespace_get(current_namespace "::")
    set(NAME_ALIAS "${current_namespace}${NAME}")
    message(VERBOSE "Creating static library ${NAME_ALIAS} v${LIB_VERSION} with root dir `${LIB_ROOT_DIR}`, (C++${LIB_CXX_VERSION})...")

    ec_parse_version("${LIB_VERSION}" LIB_VERSION)

    file(GLOB_RECURSE _lib_cpp "${LIB_ROOT_DIR}/src/*.cpp")
    file(GLOB_RECURSE _lib_hpp "${LIB_ROOT_DIR}/src/*.h" "${LIB_ROOT_DIR}/src/*.hpp")

    string(REPLACE "::" "_" NAME_ALIAS_UNDERSCORES "${NAME_ALIAS}")
    string(TOLOWER "${NAME_ALIAS_UNDERSCORES}" _lib_name_lower)
    string(TOUPPER "${NAME_ALIAS_UNDERSCORES}" _lib_name_upper)

    if(NOT LIB_NO_CONFIG)
        message(VERBOSE "Writing `${NAME}_config.h/cpp`...")
        ec_target_write_config("${NAME_ALIAS}" "${NAME}"
            ${LIB_VERSION_MAJOR} ${LIB_VERSION_MINOR} ${LIB_VERSION_PATCH} ${LIB_VERSION_TWEAK}
            "${CMAKE_CURRENT_BINARY_DIR}" "" "" _lib_extra
        )
    endif()

    add_library(${NAME} STATIC ${_lib_cpp} ${_lib_hpp} ${_lib_extra})
    # register the target globally so that it is accessible through
    # the global properties
    ec_register_target(${NAME} ${NAME_ALIAS})

    # set properties for better defaults
    ec_target_set_default_properties(${NAME} ${LIB_CXX_VERSION}
        ${ARGN}
    )

    target_include_directories(${NAME} SYSTEM PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

    if(NOT LIB_NO_INSTALL)
        # install the target
        install(TARGETS ${NAME}
            RUNTIME DESTINATION ${LIB_INSTALL_BINDIR}
            BUNDLE DESTINATION ${LIB_INSTALL_BINDIR}
            COMPONENT ${LIB_INSTALL_COMPONENT}
        )
    endif()

    message(VERBOSE "Created library ${NAME_ALIAS}.")
endfunction(ec_add_library_static)
