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
	assert(EventQueue_GetNumEvents(&queue) == 0, "should return 0 when no events have been added");

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
	assert(queue.firstEvent->nextEvent == NULL, "should set the event's next pointer to NULL if no other events were added");
	assert(EventQueue_GetNumEvents(&queue) == 1, "should return 1 when only one event was added");
	assert(EventQueue_GetFront(&queue) == &event1, "should return the first element if only one was added");

	MongooseEvent event2;
	EventQueue_PushBack(&queue, &event1); // Since it was previously removed we have to add it back or the head is NULL
	memset(&event2, 0, sizeof(MongooseEvent));

	// TODO move to EventQueue_Dump
	printf("1st event: %llx\n", (LONG_PTR) &event1);
	printf("2nd event: %llx\n", (LONG_PTR) &event2);
	printf("Queue.head: %llx\n", (LONG_PTR) queue.firstEvent);
	printf("Queue.tail: %llx\n", (LONG_PTR) queue.lastEvent);

	EventQueue_PushBack(&queue, &event2);

	// TODO move to EventQueue_Dump
	printf("1st event: %llx\n", (LONG_PTR) &event1);
	printf("2nd event: %llx\n", (LONG_PTR) &event2);
	printf("Queue.head: %llx\n", (LONG_PTR) queue.firstEvent);
	printf("Queue.tail: %llx\n", (LONG_PTR) queue.lastEvent);

	assert(queue.firstEvent == &event1, "should leave the first event in place if more events are added");
	assert(queue.lastEvent == &event2, "should update the last element whenever new events are added");
	assert(queue.firstEvent->nextEvent == &event2, "should set the event's next pointer to the second event");
	assert(queue.firstEvent->nextEvent->nextEvent == NULL, "should set the next event's next pointer to NULL");
	assert(EventQueue_GetNumEvents(&queue) == 2, "should return 2 when two events were added");
	assert(EventQueue_GetFront(&queue) == &event1, "should return the first element if more events are added");

}

static void run_all_tests() {
test_foo();
test_bar();
}

int main() {
	TestEventQueue();
	// run_all_tests();
	printf("EventQueue\tDONE\n");
}