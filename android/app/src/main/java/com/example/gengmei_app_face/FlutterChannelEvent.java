package com.example.gengmei_app_face;

import io.flutter.plugin.common.EventChannel;

class FlutterChannelEvent {

    private Object arguments;
    private EventChannel.EventSink eventSink;

    public FlutterChannelEvent(Object arguments, EventChannel.EventSink events) {
        this.arguments = arguments;
        this.eventSink = events;
    }

    public void onFaceAiLoadingEvent(String msg) {
        eventSink.success(msg);
    }

}
