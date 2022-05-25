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
	memset(&queue, 0, sizeof(EventQueue));

	// Initialization
	printf("Testing %s\n", "EventQueue_Initialize"); // implicit
	assert(queue.firstEvent == NULL, "should initialize first element with NULL");
	assert(queue.lastEvent == NULL, "should initialize last element with NULL");

	// GetFront
	printf("Testing %s\n", "EventQueue_GetFront");
	assert(EventQueue_GetFront(&queue) == NULL, "should return NULL if the list is empty");

	// PushBack
	printf("Testing %s\n", "PushBack");

	MongooseEvent event1;
	memset(&event1, 0, sizeof(MongooseEvent));
	EventQueue_PushBack(&queue, &event1);
	assert(queue.firstEvent == &event1, "should set the first element if only one event was added");
	assert(queue.lastEvent == &event1, "should set the last element if only one event was added");
	assert(EventQueue_GetFront(&queue) == &event1, "should return the first element if only one was added");

}

static void run_all_tests() {
test_foo();
test_bar();
}

int main() {
	TestEventQueue();
	// run_all_tests();
}