#include "mongoose/mongoose.h"
#include "utlist.h"

typedef char* String;

typedef struct MongooseEvent {
	int eventTypeID;
	void* eventArguments;
	struct MongooseEvent* next;
	struct MongooseEvent* prev;
} MongooseEvent;

String MongooseEvent_GetName(int enumValue) {
	switch (enumValue)
   {
      case MG_EV_ERROR: return "MG_EV_ERROR";
      case MG_EV_OPEN: return "MG_EV_OPEN";
      case MG_EV_POLL: return "MG_EV_POLL";
      case MG_EV_RESOLVE: return "MG_EV_RESOLVE";
      case MG_EV_CONNECT: return "MG_EV_CONNECT";
      case MG_EV_ACCEPT: return "MG_EV_ACCEPT";
      case MG_EV_READ: return "MG_EV_READ";
      case MG_EV_WRITE: return "MG_EV_WRITE";
      case MG_EV_CLOSE: return "MG_EV_CLOSE";
      case MG_EV_HTTP_MSG: return "MG_EV_HTTP_MSG";
      case MG_EV_HTTP_CHUNK: return "MG_EV_HTTP_CHUNK";
      case MG_EV_WS_OPEN: return "MG_EV_WS_OPEN";
      case MG_EV_WS_MSG: return "MG_EV_WS_MSG";
      case MG_EV_WS_CTL: return "MG_EV_WS_CTL";
      case MG_EV_MQTT_CMD: return "MG_EV_MQTT_CMD";
      case MG_EV_MQTT_MSG: return "MG_EV_MQTT_MSG";
      case MG_EV_MQTT_OPEN: return "MG_EV_MQTT_OPEN";
      case MG_EV_SNTP_TIME: return "MG_EV_SNTP_TIME";
      case MG_EV_USER: return "MG_EV_USER";
   }
	return "UNKNOWN_EVENT";
}

int MongooseEventList_Delete(MongooseEvent* head, MongooseEvent* elementToDelete) {
	DL_DELETE(head,elementToDelete);
    free(elementToDelete);

	return 1;
}

// MongooseEventQueue?
// typedef struct MongooseEventList {

// } MongooseEventList;

MongooseEvent* MongooseEventList_Construct() {
	MongooseEvent* head = NULL; // utlist demands this
	return head;
}