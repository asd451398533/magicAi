package com.example.gengmei_app_face

import android.os.Handler
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/**
 * @author lsy
 * @date   2019-12-17
 */
class ChannelHelper {
    val handler by lazy { Handler(App.getInstance().mainLooper) }

    companion object {
        private var instance: ChannelHelper? = null;
        private val CHANNEL_FLUTTER = "samples.flutter.io/startFaceAi_flutter"
        private var flutterChannelEvent: FlutterChannelEvent? = null

        @JvmStatic
        fun getInstance(): ChannelHelper {
            if (instance == null) {
                instance = ChannelHelper();
            }
            return instance!!
        }
    }


    fun resign(binner: BinaryMessenger) {
        EventChannel(binner, CHANNEL_FLUTTER).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any, events: EventChannel.EventSink) {
                        flutterChannelEvent = FlutterChannelEvent(arguments, events)
                        Log.e("lsy", "  Listener !!  ")
                    }

                    override fun onCancel(arguments: Any) {}
                }
        )
    }


}