#include <gtest/gtest.h>
#include <cstdint>

uint32_t factorial(uint32_t n) {
    return n <= 1 ? 1u : n * factorial(n - 1);
}

TEST(FactorialTest, Computes) {
    EXPECT_EQ(factorial(1), 1u);
    EXPECT_EQ(factorial(2), 2u);
    EXPECT_EQ(factorial(3), 6u);
    EXPECT_EQ(factorial(10), 3'628'800u);
}
