/* file minunit_example.c */

 #include <stdio.h>

 typedef char * String;
 typedef int bool;

#define true 1
#define false 0

static bool assert(bool condition, String message)
{
	if (!condition) {
		printf("FAIL\t %s\n", message);
		return true;
	}

	printf("OK\t %s\n", message);
	return false;
}


 int tests_run = 0;

 int foo = 7;
 int bar = 4;


 static String test_foo() {
     assert(foo == 7, "foo should be 7");
     return 0;
 }

 static String test_bar() {
     assert(bar == 5, "bar should be 5");
     return 0;
 }

 static String run_all_tests() {
	test_foo();
	test_bar();
	return 0;
 }

 int main() {
     String result = run_all_tests();
     if (result != 0) {
         printf("FAIL\t%s\n", result);
     }

     return result != 0;
 }