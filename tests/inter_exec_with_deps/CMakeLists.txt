include(ECNamespace)
include(ECExecutable)
include(ECLibrary)

ec_add_executable(exec_with_deps ROOT_DIR "exec")
ec_add_library_dynamic(dylib ROOT_DIR "dylib")
ec_add_library_static(stlib ROOT_DIR "stlib")

target_link_libraries(tests-inter-exec_with_deps PUBLIC tests-inter-dylib tests-inter-stlib)

ec_get_linked_shared_targets(tests-inter-exec_with_deps all_deps)
message(VERBOSE "Found `inter_exec_dylib::exec_with_deps` runtime dependencies: ${all_deps}")