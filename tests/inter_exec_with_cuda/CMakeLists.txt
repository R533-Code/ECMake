include(ECExecutable)

# must be called at file scope, before `ec_add_executable(... WITH_CUDA)`
enable_language(CUDA)

ec_add_executable(exec_with_cuda WITH_CUDA)