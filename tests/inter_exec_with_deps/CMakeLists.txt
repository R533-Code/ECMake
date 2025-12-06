include(ECNamespace)
include(ECExecutable)
include(ECLibrary)

ec_add_library_dynamic(dylib ROOT_DIR "dylib" OUT _dylib)
ec_add_library_static(stlib ROOT_DIR "stlib" OUT _stlib)
ec_add_executable(exec_with_deps OUT _exec
    ROOT_DIR "exec"
    LINK_WITH PUBLIC ${_dylib} ${_stlib}
)

ec_get_linked_shared_targets(${_exec} all_deps)
message(VERBOSE "Found `${_exec}` runtime dependencies: ${all_deps}")