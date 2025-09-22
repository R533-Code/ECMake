#include <pybind11/pybind11.h>

static int sum(int a, int b) noexcept
{
    return a + b;
}

void bind_python_example(pybind11::module_& mod)
{
    mod.def("sum", &sum);
}