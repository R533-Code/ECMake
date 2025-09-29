include(ECNamespace)
include(ECExecutable)
include(ECLibrary)

ec_add_executable(exec_with_deps ROOT_DIR "exec")
ec_add_library_dynamic(dylib ROOT_DIR "dylib")
ec_add_library_static(stlib ROOT_DIR "stlib")

ec_get_target(exec_with_deps _exec)
ec_get_target(dylib _dylib)
ec_get_target(stlib _stlib)

target_link_libraries(${_exec} PUBLIC ${_dylib} ${_stlib})

ec_get_linked_shared_targets(${_exec} all_deps)
message(VERBOSE "Found `${_exec}` runtime dependencies: ${all_deps}")