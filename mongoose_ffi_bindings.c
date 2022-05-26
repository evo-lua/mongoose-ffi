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

  	printf("OnMongooseEvent: %s\n", MongooseEvent_GetName(eventID));

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
	DL_PREPEND(listHead, newEvent); // The queue is FIFO, but we can only get the head in constant time... so new events must go first

	// TODO Remove after debugging/writing tests, move to dump function (MongooseEventQueue_Dump)
	MongooseEvent* elt;
	DL_FOREACH(listHead,elt) printf("Event Type ID: %d\n", elt->eventTypeID);
	int count;
    DL_COUNT(listHead, elt, count);

  if (eventID == MG_EV_HTTP_MSG) mg_http_serve_dir(connection, eventData, &opts);
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
