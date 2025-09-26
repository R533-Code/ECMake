#include "version.h"
#include <cuda.h>
#include <cstdio>

void print_version()
{
    printf("CUDA v%i.%i\n", CUDA_VERSION / 1000, CUDA_VERSION / 10 % 100);
}