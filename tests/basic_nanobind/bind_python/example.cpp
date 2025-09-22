#include <nanobind/nanobind.h>

static int sum(int a, int b) noexcept
{
    return a + b;
}

void bind_python_example(nanobind::module_& mod)
{
    mod.def("sum", &sum);
}