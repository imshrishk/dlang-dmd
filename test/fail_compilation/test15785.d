// PERMUTE_ARGS:
// EXTRA_FILES: imports/test15785.d
/*
TEST_OUTPUT:
---
fail_compilation/test15785.d(17): Error: no property `foo` for type `imports.test15785.Base`
fail_compilation/test15785.d(18): Error: undefined identifier `bar`
---
*/

import imports.test15785;

class Derived : Base
{
    void test()
    {
        super.foo();
        bar();
    }
}
