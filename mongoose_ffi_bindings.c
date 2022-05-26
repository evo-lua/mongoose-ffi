#include "mongoose/mongoose.h"

#include <stdio.h>
#include "utlist.h"

// The readability of C programs clearly could be improved with saner naming schemes...
typedef struct mg_addr MongooseNetworkAddress;
typedef struct mg_mgr MongooseEventManager;
typedef struct mg_connection MongooseConnection;

typedef char* String;


// #include "EventQueue.c"
#include "MongooseEvent.c"
#include "debug.c"

static void OnMongooseEvent(MongooseConnection *connection, int eventID, void *eventData, void *userData) {
	struct mg_http_serve_opts opts = {.root_dir = "."};   // Serve local dir

  	printf("Triggered OnMongooseEvent: %s\n", MongooseEvent_GetName(eventID));

	if(eventID == MG_EV_POLL) return; // Not relevant


	// TODO Ensure they are always freed (valgrind + tests / actions workflow)
	MongooseEvent* listHead = (MongooseEvent*) userData; // From MongooseEventManager_CreateHttpServer
	MongooseEvent* newEvent = (MongooseEvent *) malloc(sizeof(MongooseEvent));
	if(newEvent == NULL) {
		printf("Fatal error: Failed to allocate memory for MongooseEvent! Exiting...\n");
		exit(EXIT_FAILURE);
	}

	// MongooseEvent* newEvent = malloc(sizeof(MongooseEvent));
	newEvent->eventTypeID = eventID;
	newEvent->eventArguments = eventData;
	DL_APPEND(listHead, newEvent); // The queue is FIFO, but we can only get the head in constant time... so new events must go first

	// TODO Remove after debugging/writing tests, move to dump function (MongooseEventQueue_Dump)
	MongooseEvent* elt;
	DL_FOREACH(listHead,elt) printf("[DL_FOREACH] Event Type ID: %d (%s)\n", elt->eventTypeID, MongooseEvent_GetName(eventID));
	int count;
    DL_COUNT(listHead, elt, count);
	DL_FOREACH(listHead,elt) printf("[DL_COUNT] Number of Queued Events: %d\n", count);

	// userData = (void*)listHead;
	// To ensure the queued events are persisted (mongoose will pass them on, but otherwise ignores the contents)
	connection->fn_data = listHead;

  	if (eventID == MG_EV_HTTP_MSG) {
		DEBUG("Serving root directory...\n");
		  mg_http_serve_dir(connection, eventData, &opts);
	}
	DEBUG("OnMongooseEvent handling finished");
}

// FFI Exports: These functions should be exposed to Lua
MongooseEventManager MongooseEventManager_CreateHttpServer() {

	DEBUG("MongooseEventManager_CreateHttpServer");

	struct mg_mgr mgr;

	// EventQueue eventQueue;
	// eventQueue.firstEvent= NULL;
	// eventQueue.lastEvent= NULL;

	MongooseEvent* eventList = MongooseEventList_Construct();

	mg_mgr_init(&mgr);
	mg_http_listen(&mgr, "0.0.0.0:8000", OnMongooseEvent, eventList);     // Create listening connection
//   for (;;) mg_mgr_poll(&mgr, 1000);                   // Block forever
	return mgr;
}

void MongooseEventManager_PollOnceWithTimeout(MongooseEventManager eventManager, int timeoutInMilliseconds) {
	DEBUG("MongooseEventManager_PollOnceWithTimeout");
	mg_mgr_poll(&eventManager, timeoutInMilliseconds);
}

// TBD Maybe expose all the structs and let Lua handle this?
void Mongoose_CreateWebSocketServer() {}
void Mongoose_CreateTcpServer() {}
void Mongoose_CreateUdpServer() {}

// GetSocketEvents(mgr)
// iterate through list until next is NULL

// int main() {

//   struct mg_mgr mgr;
//   mg_mgr_init(&mgr);
//   mg_http_listen(&mgr, "0.0.0.0:8000", OnMongooseEvent, NULL);     // Create listening connection
//   for (;;) mg_mgr_poll(&mgr, 1000);                   // Block forever
// }
