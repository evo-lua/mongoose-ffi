#include "mongoose/mongoose.h"

#include <stdio.h>


// The readability of C programs clearly could be improved with saner naming schemes...
typedef struct mg_addr MongooseNetworkAddress;
typedef struct mg_mgr MongooseEventManager;
typedef struct mg_connection MongooseConnection;

typedef char* String;




#include "EventQueue.c"
#include "debug.h"

static void OnMongooseEvent(MongooseConnection *connection, int eventID, void *eventData, void *userData) {
	// DEBUG("OnMongooseEvent");

  struct mg_http_serve_opts opts = {.root_dir = "."};   // Serve local dir


	// switch(event) {
		// case ... :
	// }

	EventQueue* eventQueue = (EventQueue*) userData;
	EventQueue_PrintEvents(eventQueue);
  	printf("OnMongooseEvent: %s\n", GetMongooseEventName(eventID));


	MongooseEvent* newEvent = malloc(sizeof(MongooseEvent));
	newEvent->eventTypeID = eventID;
	newEvent->eventArguments = eventData;
	EventQueue_PushBack(eventQueue, newEvent);

  if (eventID == MG_EV_HTTP_MSG) mg_http_serve_dir(connection, eventData, &opts);
}

// FFI Exports: These functions should be exposed to Lua
MongooseEventManager MongooseEventManager_CreateHttpServer() {

	DEBUG("MongooseEventManager_CreateHttpServer");

	struct mg_mgr mgr;

	EventQueue eventQueue;
	eventQueue.firstEvent= NULL;
	eventQueue.lastEvent= NULL;

	mg_mgr_init(&mgr);
	mg_http_listen(&mgr, "0.0.0.0:8000", OnMongooseEvent, &eventQueue);     // Create listening connection
  //for (;;) mg_mgr_poll(&mgr, 1000);                   // Block forever
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
