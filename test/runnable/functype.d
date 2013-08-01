extern(C) int printf(const char*, ...);

/***************************************************/

void testfp()
{
    static int func1(int n = 1) { return n; }
    static int func2(int n    ) { return n; }
    static assert(typeof(func1).stringof == "int(int n = 1)");
    static assert(typeof(func2).stringof == "int(int n)");
    static assert( is(typeof(func1())));     // OK
    static assert(!is(typeof(func2())));     // NG

    alias typeof(func1) Func1;
    alias typeof(func2) Func2;
    static assert(is(Func1 == Func2));
    static assert(Func1.stringof == "int(int n = 1)");
    static assert(Func2.stringof == "int(int n)");

    auto fp1 = &func1;
    auto fp2 = &func2;
    static assert(typeof(fp1).stringof == "int function(int n = 1)");
    static assert(typeof(fp2).stringof == "int function(int n)");
    static assert( is(typeof(fp1())));     // OK
    static assert(!is(typeof(fp2())));     // NG

    alias typeof(fp1) Fp1;
    alias typeof(fp2) Fp2;
    static assert(is(Fp1 == Fp2));
    static assert(Fp1.stringof == "int function(int n = 1)");
    static assert(Fp2.stringof == "int function(int n)");

    typeof(fp1) fp3 = fp1;
    typeof(fp2) fp4 = fp2;
    static assert(is(typeof(fp3) == typeof(fp4)));
    static assert(typeof(fp3).stringof == "int function(int n = 1)");
    static assert(typeof(fp4).stringof == "int function(int n)");
    static assert( is(typeof(fp3())));     // OK
    static assert(!is(typeof(fp4())));     // NG

    alias typeof(fp3) Fp3;
    alias typeof(fp4) Fp4;
    static assert(is(Fp3 == Fp4));
    static assert(Fp3.stringof == "int function(int n = 1)");
    static assert(Fp4.stringof == "int function(int n)");

    auto fplit1 = function(int n = 1) { return n; };
    auto fplit2 = function(int n    ) { return n; };
    static assert( is(typeof(fplit1())));   // OK
    static assert(!is(typeof(fplit2())));   // NG
}

void testdg()
{
    int nest1(int n = 1) { return n; }
    int nest2(int n    ) { return n; }
    static assert(typeof(nest1).stringof == "int(int n = 1)");
    static assert(typeof(nest2).stringof == "int(int n)");
    static assert( is(typeof(nest1())));     // OK
    static assert(!is(typeof(nest2())));     // NG

    alias typeof(nest1) Nest1;
    alias typeof(nest2) Nest2;
    static assert(is(Nest1 == Nest2));
    static assert(Nest1.stringof == "int(int n = 1)");
    static assert(Nest2.stringof == "int(int n)");

    auto dg1 = &nest1;
    auto dg2 = &nest2;
    static assert(typeof(dg1).stringof == "int delegate(int n = 1)");
    static assert(typeof(dg2).stringof == "int delegate(int n)");
    static assert( is(typeof(dg1())));     // OK
    static assert(!is(typeof(dg2())));     // NG

    alias typeof(dg1) Dg1;
    alias typeof(dg2) Dg2;
    static assert(is(Dg1 == Dg2));
    static assert(Dg1.stringof == "int delegate(int n = 1)");
    static assert(Dg2.stringof == "int delegate(int n)");

    typeof(dg1) dg3 = dg1;
    typeof(dg2) dg4 = dg2;
    static assert(typeof(dg3).stringof == "int delegate(int n = 1)");
    static assert(typeof(dg4).stringof == "int delegate(int n)");
    static assert( is(typeof(dg3())));     // OK
    static assert(!is(typeof(dg4())));     // NG

    alias typeof(dg3) Dg3;
    alias typeof(dg4) Dg4;
    static assert(is(Dg3 == Dg4));
    static assert(Dg3.stringof == "int delegate(int n = 1)");
    static assert(Dg4.stringof == "int delegate(int n)");

    auto dglit1 = delegate(int n = 1) { return n; };
    auto dglit2 = delegate(int n    ) { return n; };
    static assert( is(typeof(dglit1())));   // OK
    static assert(!is(typeof(dglit2())));   // NG
}

void testda()
{
    // Unsupported cases with current implementation.

    int function(int n = 1)[] fpda = [n => n + 1, n => n+2];
    assert(fpda[0](1) == 2);
    assert(fpda[1](1) == 3);
    static assert(!is(typeof(fpda[0]() == 1)));     // cannot call with using defArgs
    static assert(!is(typeof(fpda[1]() == 2)));     // cannot call with using defArgs
    static assert(typeof(fpda).stringof == "int function(int)[]");
    static assert(typeof(fpda).stringof != "int funciton(int n = 1)[]");

    int delegate(int n = 1)[] dgda = [n => n + 1, n => n+2];
    assert(dgda[0](1) == 2);
    assert(dgda[1](1) == 3);
    static assert(!is(typeof(dgda[0]() == 1)));     // cannot call with using defArgs
    static assert(!is(typeof(dgda[1]() == 2)));     // cannot call with using defArgs
    static assert(typeof(dgda).stringof == "int delegate(int)[]");
    static assert(typeof(fpda).stringof != "int delegate(int n = 1)[]");
}

template StringOf(T)
{
    // template type parameter cannot have redundant informations
    enum StringOf = T.stringof;
}

void testti()
{
    int[] test(int[] a = []) { return a; }
    static assert(typeof(test).stringof == "int[](int[] a = [])");
    static assert(StringOf!(typeof(test)) == "int[](int[])");

    float function(float x = 0F) fp = x => x;
    static assert(typeof(fp).stringof == "float function(float x = " ~ (0F).stringof ~ "F)");
    static assert(StringOf!(typeof(fp)) == "float function(float)");

    double delegate(double x = 0.0) dg = x => x;
    static assert(typeof(dg).stringof == "double delegate(double x = " ~ (0.0).stringof ~ ")");
    static assert(StringOf!(typeof(dg)) == "double delegate(double)");

    template F(T) {}
    auto fp1 = (int a = 1) {};
    auto fp2 = (int b = 2) {};
    static assert(typeof(fp1).stringof != typeof(fp2).stringof);
    alias F1 = F!(typeof(fp1));
    alias F2 = F!(typeof(fp2));
    static assert(__traits(isSame, F1, F2));
    static assert(F1.mangleof == F2.mangleof);
}

void testxx()
{
    // The corner cases which I had introduced in forum discussion

    // f will inherit default args from its initializer, if it's declared with 'auto'
    auto f1 = (int n = 10){ return 10; };
    assert(f1() == 10);

    // what is the actual default arg of f?
    int function(int n = 10) f2 = (int n = 20){ return n; };
    int function(int n     ) f3 = (int n = 30){ return n; };
    int function(int n = 40) f4 = (int n     ){ return n; };
    assert(f2() == 10);
    static assert(!is(typeof(f3())));
    assert(f4() == 40);

    // conditional expression and the type of its result
    auto f5 = true ? (int n = 10){ return n; }
                   : (int n = 20){ return n; } ;
    auto f6 = true ? (int n = 10, string s = "hello"){ return n; }
                   : (int n = 10, string s = "world"){ return n; } ;
    static assert(!is(typeof(f5())));   // cannot call
    static assert(!is(typeof(f6())));   // cannot call

    int function(int n = 10) f7;    // default arg of the first parameter is 10
    f7 = (int n = 20){ return n; }; // function literal's default arg will be ignored
    assert(f7() == 10);

    // returning function pointer/delegate type can have default args
    int delegate(int n = 10) foo(int x) { return n => n + x; }
    auto f = foo(1);
    assert(f() == 11);
}

/***************************************************/
// 3646

int bar3646(int x = 10) { printf("bar %d\n", x); return x; }
int bam3646(int y)      { printf("bam %d\n", y); return y; }

int qux3646()      { printf("quux\n");       return 20; }
int qux3646(int i) { printf("quux %d\n", i); return 30; }

void foo3646a(Fn)(Fn fn)
{
    fn();
}

void foo3646b(alias fn)(int res1, int res2)
{
    assert(fn() == res1);
    assert(fn(42) == res2);
}

void test3646()
{
    static assert(!is(typeof(foo3646(&bar3646))));
    static assert(!is(typeof(foo3646(&bam3646))));
    static assert(typeof(&bar3646).stringof == "int function(int x = 10)");
    static assert(typeof(&bam3646).stringof == "int function(int y)");

    foo3646b!bar3646(10, 42);
    static assert(!is(typeof(foo3646b!bam3646(0, 0))));
    foo3646b!qux3646(20, 30);
}

/***************************************************/
// 3866

void test3866()
{

    auto foo = (int a = 1) { return a; };
    auto bar = (int a) { return a; };

    assert(foo() == 1);
    static assert(!is(typeof(bar())));
    assert(foo(2) == 2);
    assert(bar(3) == 3);
}

/***************************************************/
// 8579

void test8579()
{
    static void func1(int i, double j = 1.0) {}
    static void func2(int x, double y) {}
    auto fn1 = &func1;
    auto fn2 = &func2;
    static assert(is(typeof(fn1) == typeof(fn2)));
           assert(   typeid(fn1) is typeid(fn2) );
    static assert(typeof(fn1).stringof == "void function(int i, double j = " ~ (1.0).stringof ~ ")");
    static assert(typeof(fn2).stringof == "void function(int x, double y)");

    static int func3(int x, double y) { return 0; }
    static int func4(int i, double j = 1.0) { return 0; }
    auto fn3 = &func3;
    auto fn4 = &func4;
    static assert(is(typeof(fn3) == typeof(fn4)));
           assert(   typeid(fn3) is typeid(fn4) );
    static assert(typeof(fn3).stringof == "int function(int x, double y)");
    static assert(typeof(fn4).stringof == "int function(int i, double j = " ~ (1.0).stringof ~ ")");
}

/***************************************************/
// 10734

// There's no platform independent export symbol, so
// test just only in Win32.
version(Win32)
{

extern(Windows)
{
    export uint DefWindowProcA(void*, uint, uint, ptrdiff_t);
    alias uint function (void*, uint, uint, ptrdiff_t) WNDPROC;
}

void test10734()
{
    WNDPROC lpfnWndProc = &DefWindowProcA;
}

}

/***************************************************/

int main()
{
    testfp();
    testdg();
    testda();
    testti();
    testxx();
    test3646();
    test3866();
    test8579();

    printf("Success\n");
    return 0;
}

