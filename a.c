__attribute((section("abc")))
int a = 1;

__attribute((section("abc")))
int b = 2;

__attribute((section("abc")))
int c = 3;

__attribute((section("def")))
int d = 4;

__attribute((section("def")))
int e = 5;

__attribute((section("def")))
int f = 6;

__attribute((section("abc")))
void *m = (void *) &f;