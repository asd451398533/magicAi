package com.example.gengmei_app_face.util

import android.graphics.Paint
import android.os.Handler
import android.text.TextUtils
import android.util.Log
import android.view.View
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import java.io.File
import java.text.SimpleDateFormat


/**
 * Created by lsy
 * on 2019/4/18
 */

fun Any?.isNull(): Boolean {
    return this == null
}


fun String.splitU(s: String): List<String>? {
    if (this.contains(s)) {
        return this.split(s)
    }
    return null
}

fun Disposable?.addTo(disposable: CompositeDisposable?) {
    if (disposable != null && this != null) {
        disposable.add(this)
    }
}

fun String?.empty(): Boolean {
    return TextUtils.isEmpty(this)
}

