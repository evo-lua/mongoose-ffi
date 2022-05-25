#include "mongoose/mongoose.h"

#include <stdio.h>

#define DEBUG_MODE 1


// The readability of C programs clearly could be improved with saner naming schemes...
typedef struct mg_addr MongooseNetworkAddress;
typedef struct mg_mgr MongooseEventManager;
typedef struct mg_connection MongooseConnection;

typedef char* String;

static void DEBUG(String message) {
#ifdef DEBUG_MODE
	printf("[DEBUG] %s\n", message);
#endif

};


static String GetMongooseEventName(int enumValue) {
	switch (enumValue)
   {
//   MG_EV_ERROR,       // Error                        char *error_message
      case MG_EV_ERROR: return "MG_EV_ERROR";
//   MG_EV_OPEN,        // Connection created           NULL
      case MG_EV_OPEN: return "MG_EV_OPEN";
//   MG_EV_POLL,        // mg_mgr_poll iteration        uint64_t *milliseconds
      case MG_EV_POLL: return "MG_EV_POLL";
//   MG_EV_RESOLVE,     // Host name is resolved        NULL
      case MG_EV_RESOLVE: return "MG_EV_RESOLVE";
//   MG_EV_CONNECT,     // Connection established       NULL
      case MG_EV_CONNECT: return "MG_EV_CONNECT";
//   MG_EV_ACCEPT,      // Connection accepted          NULL
      case MG_EV_ACCEPT: return "MG_EV_ACCEPT";
//   MG_EV_READ,        // Data received from socket    struct mg_str *
      case MG_EV_READ: return "MG_EV_READ";
//   MG_EV_WRITE,       // Data written to socket       long *bytes_written
      case MG_EV_WRITE: return "MG_EV_WRITE";
//   MG_EV_CLOSE,       // Connection closed            NULL
      case MG_EV_CLOSE: return "MG_EV_CLOSE";
//   MG_EV_HTTP_MSG,    // HTTP request/response        struct mg_http_message *
      case MG_EV_HTTP_MSG: return "MG_EV_HTTP_MSG";
//   MG_EV_HTTP_CHUNK,  // HTTP chunk (partial msg)     struct mg_http_message *
      case MG_EV_HTTP_CHUNK: return "MG_EV_HTTP_CHUNK";
//   MG_EV_WS_OPEN,     // Websocket handshake done     struct mg_http_message *
      case MG_EV_WS_OPEN: return "MG_EV_WS_OPEN";
//   MG_EV_WS_MSG,      // Websocket msg, text or bin   struct mg_ws_message *
      case MG_EV_WS_MSG: return "MG_EV_WS_MSG";
//   MG_EV_WS_CTL,      // Websocket control msg        struct mg_ws_message *
      case MG_EV_WS_CTL: return "MG_EV_WS_CTL";
//   MG_EV_MQTT_CMD,    // MQTT low-level command       struct mg_mqtt_message *
      case MG_EV_MQTT_CMD: return "MG_EV_MQTT_CMD";
//   MG_EV_MQTT_MSG,    // MQTT PUBLISH received        struct mg_mqtt_message *
      case MG_EV_MQTT_MSG: return "MG_EV_MQTT_MSG";
//   MG_EV_MQTT_OPEN,   // MQTT CONNACK received        int *connack_status_code
      case MG_EV_MQTT_OPEN: return "MG_EV_MQTT_OPEN";
//   MG_EV_SNTP_TIME,   // SNTP time received           uint64_t *milliseconds
      case MG_EV_SNTP_TIME: return "MG_EV_SNTP_TIME";
//   MG_EV_USER,        // Starting ID for user events
      case MG_EV_USER: return "MG_EV_USER";
// };
      /* etc... */
   }
	return "UNKNOWN_EVENT";
}

typedef struct MongooseEvent {
	int eventTypeID;
	void* eventArguments;
	struct MongooseEvent* nextEvent;
} MongooseEvent;

typedef struct EventQueue {
	MongooseEvent* firstEvent;
	MongooseEvent* lastEvent;
} EventQueue;

MongooseEvent* EventQueue_GetFront(EventQueue* eventQueue) {
	DEBUG("EventQueue_GetFront");

	MongooseEvent* event;
	if((event = eventQueue->firstEvent) != NULL) {
		eventQueue->firstEvent = event->nextEvent;
	}

	return eventQueue->firstEvent;
}

void MongooseEvent_DebugPrint(MongooseEvent* event) {
	DEBUG(GetMongooseEventName(event->eventTypeID));
}

void EventQueue_PrintEvents(EventQueue* eventQueue) {
	DEBUG("EventQueue_PrintEvents");

	if(eventQueue->firstEvent == NULL) DEBUG("Event Queue is empty!");

	MongooseEvent* event = eventQueue->firstEvent;
	while(event != NULL) {
		MongooseEvent_DebugPrint(event);
		event = event->nextEvent;
	}
}

bool EventQueue_PushBack(EventQueue* eventQueue, MongooseEvent* event) {
	DEBUG("EventQueue_PushBack");

	// List is empty -> new event is first and last
	if(eventQueue->firstEvent == NULL) {
		eventQueue->firstEvent = event;
	}

	if(eventQueue->lastEvent == NULL) {
		eventQueue->lastEvent = event;
	}

	// List has two or more elements -> new event should be appended
	eventQueue->lastEvent->nextEvent = event;

	return true;
}

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
