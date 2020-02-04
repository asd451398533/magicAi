package com.example.gengmei_app_face

/**
 * @author lsy
 * @date   2019-12-26
 */
class WelcomeInstance {

    var isInit = false;

    companion object {
        val instance: WelcomeInstance by lazy(mode = LazyThreadSafetyMode.SYNCHRONIZED) {
            WelcomeInstance()
        }
    }
}