include(ECNamespace)
include(ECExecutable)
include(ECLibraryDynamic)
include(ECLibraryStatic)

ec_namespace(inter_exec_with_deps)

ec_add_executable(exec_with_deps ROOT_DIR "exec")
ec_add_library_dynamic(dylib ROOT_DIR "dylib")
ec_add_library_static(stlib ROOT_DIR "stlib")

target_link_libraries(exec_with_deps PUBLIC dylib stlib)

ec_get_linked_shared_targets(exec_with_deps all_deps)
message(VERBOSE "Found `inter_exec_dylib::exec_with_deps` runtime dependencies: ${all_deps}")

ec_endnamespace(inter_exec_with_deps)