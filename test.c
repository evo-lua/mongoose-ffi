/* file minunit_example.c */

#include <stdio.h>

#include "EventQueue.c"

typedef char * String;
// typedef int bool;

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

static void TestEventQueue() {

	EventQueue queue;

	// Initialization
	assert(queue.firstEvent == NULL, "should initialize first element with NULL");
	assert(queue.lastEvent == NULL, "should initialize last element with NULL");

	// PushBack

	// PushBack
}

static void run_all_tests() {
test_foo();
test_bar();
}

int main() {
	TestEventQueue();
	// run_all_tests();
}