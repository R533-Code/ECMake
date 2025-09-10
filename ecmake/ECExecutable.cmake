include(ECMake)
include(ECNamespace)
include(ECParseArgs)

function(ec_add_executable NAME)
    ec_parse_with_defaults(EXEC
        "VERSION;0.0.0.0;ROOT_DIR;${CMAKE_CURRENT_SOURCE_DIR};CXX_VERSION;20" # defaults
        "" # options
        "VERSION;ROOT_DIR;CXX_VERSION" # one value
        "" # multi value
        ${ARGN}
    )

    ec_namespace_get(current_namespace)
    set(NAME_ALIAS "${current_namespace}${NAME}")
    message(VERBOSE "Creating executable ${NAME_ALIAS} v${EXEC_VERSION} with root dir `${EXEC_ROOT_DIR}`, (C++${EXEC_CXX_VERSION})...")

    file(GLOB_RECURSE _exec_cpp "${EXEC_ROOT_DIR}/src/*.cpp")
    file(GLOB_RECURSE _exec_hpp "${EXEC_ROOT_DIR}/src/*.h" "${EXEC_ROOT_DIR}/src/*.hpp")

    add_executable(${NAME} ${_exec_cpp} ${_exec_h})
    add_executable(${NAME_ALIAS} ALIAS ${NAME})

    set_target_properties(${NAME} PROPERTIES
        CXX_STANDARD "${EXEC_CXX_VERSION}"
        CXX_STANDARD_REQUIRED TRUE
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN hidden
    )

    if(MSVC)
        target_compile_options(${NAME} PRIVATE "/Zc:preprocessor")
        message(VERBOSE "Adding conformant preprocessor (for MSVC)")
    endif()
endfunction(ec_add_executable)
