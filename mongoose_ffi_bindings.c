#include "mongoose/mongoose.h"

#include <stdio.h>

// The readability of C programs clearly could be improved with saner naming schemes...
typedef struct mg_addr MongooseNetworkAddress;
typedef struct mg_mgr MongooseEventManager;
typedef struct mg_connection MongooseConnection;

typedef char* String;

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

typedef struct {
	int eventTypeID;
	// TBD: Redundant, eliminate and use LUT in Lua?
	String eventName;
	void* eventArguments; // Also needs a LUT since the types are different...
} MongooseEvent;

typedef struct {
	int numEvents;
	MongooseEvent** events; // TBD Does that work with the args being void pointers? Maybe not, could use fixed event types, one per enum value
} EventQueue;


static void OnMongooseEvent(MongooseConnection *connection, int event, void *eventData, void *userData) {
  struct mg_http_serve_opts opts = {.root_dir = "."};   // Serve local dir


  printf("OnMongooseEvent: %s\n", GetMongooseEventName(event));
  if (event == MG_EV_HTTP_MSG) mg_http_serve_dir(connection, eventData, &opts);
}

// FFI Exports: These functions should be exposed to Lua
void CreateHttpServer() {
  struct mg_mgr mgr;
  mg_mgr_init(&mgr);
  mg_http_listen(&mgr, "0.0.0.0:8000", OnMongooseEvent, NULL);     // Create listening connection
  for (;;) mg_mgr_poll(&mgr, 1000);                   // Block forever
}

// TBD Maybe expose all the structs and let Lua handle this?
void CreateWebSocketServer() {}
void CreateTcpServer() {}
void CreateUdpServer() {}



// int main() {

//   struct mg_mgr mgr;
//   mg_mgr_init(&mgr);
//   mg_http_listen(&mgr, "0.0.0.0:8000", OnMongooseEvent, NULL);     // Create listening connection
//   for (;;) mg_mgr_poll(&mgr, 1000);                   // Block forever
// }
