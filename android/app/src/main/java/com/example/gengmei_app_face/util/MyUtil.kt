package com.example.gengmei_app_face.util

import android.content.Context
import android.util.Log
import com.example.myimagepicker.luban.Luban
import java.io.File
import android.media.ThumbnailUtils
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.DebugUtils
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.lang.Exception
import android.view.ViewGroup
import android.app.Activity
import android.view.WindowManager
import android.os.Build
import android.annotation.TargetApi
import android.graphics.Color
import android.graphics.Matrix
import android.view.View
import android.R.attr.bitmap
import android.opengl.ETC1.getHeight
import android.opengl.ETC1.getWidth




/**
 * @author lsy
 * @date   2019-09-10
 */

class MyUtil {


    companion object {
        val matrix = Matrix()
        fun getImageCacheDir(context: Context, cacheName: String): File? {
            val cacheDir = context.externalCacheDir
            if (cacheDir != null) {
                val result = File(cacheDir, cacheName)
                return if (!result.mkdirs() && (!result.exists() || !result.isDirectory)) {
                    // File wasn't able to create a directory, or the result exists but not a directory
                    null
                } else result
            }
            if (Log.isLoggable(Luban.TAG, Log.ERROR)) {
                Log.e(Luban.TAG, "default disk cache dir is null")
            }
            return null
        }


        fun getFileName(pathandname: String): String? {
            val start = pathandname.lastIndexOf("/")
            val end = pathandname.lastIndexOf(".")
            return if (start != -1 && end != -1) {
                pathandname.substring(start + 1, end)
            } else {
                null
            }
        }

        fun getFileFullName(pathandname: String): String? {
            val start = pathandname.lastIndexOf("/")
            val end = pathandname.lastIndexOf(".")
            return if (start != -1 && end != -1) {
                pathandname.substring(start + 1, pathandname.length)
            } else {
                null
            }
        }

        fun saveVideoImg(filePath: String, videoPath: String, kind: Int, width: Int, height: Int): String {
            val file = File(filePath);
            var bitmap: Bitmap? = null
            // 获取视频的缩略图
            bitmap = ThumbnailUtils.createVideoThumbnail(videoPath, kind)
            if (width > 0 && height > 0) {
                bitmap = ThumbnailUtils.extractThumbnail(bitmap, width, height,
                        ThumbnailUtils.OPTIONS_RECYCLE_INPUT)
            }
            try {
                val out = FileOutputStream(file)
                bitmap.compress(Bitmap.CompressFormat.PNG, 80, out)
                out.flush()
                out.close()
                bitmap.recycle()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            return filePath
        }

        fun scareImg(imgPath: String, scareSize: Float, filePath: String, quality: Int,degree:Int): String {
            val newOpts = BitmapFactory.Options()
            // 开始读入图片，此时把options.inJustDecodeBounds 设回true，即只读边不读内容
            newOpts.inJustDecodeBounds = true
            newOpts.inPreferredConfig = Bitmap.Config.RGB_565
            // 获取位图信息，但请注意位图现在为空
            var bitmap = BitmapFactory.decodeFile(imgPath, newOpts)

            newOpts.inJustDecodeBounds = false
            val w = newOpts.outWidth
            val h = newOpts.outHeight

            val max = Math.max(w, h)
            var scare = 1f
            if (max > scareSize) {
                scare = max / scareSize
            }
            // 想要缩放的目标尺寸,现在大部分手机都是1080*1920，参考值可以让宽高都缩小一倍
            //        float hh = w * scare;// 设置高度为960f时，可以明显看到图片缩小了
            //        float ww = h * scare;// 设置宽度为540f，可以明显看到图片缩小了
            //        // 缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
            //        int be = 1;// be=1表示不缩放
            //        if (w > h && w > ww) {// 如果宽度大的话根据宽度固定大小缩放
            //            be = (int) (newOpts.outWidth / ww);
            //        } else if (w < h && h > hh) {// 如果高度高的话根据宽度固定大小缩放
            //            be = (int) (newOpts.outHeight / hh);
            //        }
            //        if (be <= 0)
            //            be = 1;
            newOpts.inSampleSize = scare.toInt()// 设置缩放比例
            // 开始压缩图片，注意此时已经把options.inJustDecodeBounds 设回false了
            bitmap = BitmapFactory.decodeFile(imgPath, newOpts)
            val file = File(filePath)
            try {
                val out = FileOutputStream(file)
                if(degree!=0){
                    matrix.reset()
                    matrix.postRotate(degree.toFloat());
                    val resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0,
                            bitmap.width, bitmap.height, matrix, true)
                    resizedBitmap.compress(Bitmap.CompressFormat.PNG, quality, out)
                    resizedBitmap.recycle()
                }else{
                    bitmap.compress(Bitmap.CompressFormat.PNG, quality, out)
                }
                out.flush()
                out.close()
                bitmap.recycle()
            } catch (e: FileNotFoundException) {
                e.printStackTrace()
            } catch (e: IOException) {
                e.printStackTrace()
            }
            return filePath
        }

        fun scareImg(imgPath: String, scareSize: Float): Bitmap {
            val newOpts = BitmapFactory.Options()
            // 开始读入图片，此时把options.inJustDecodeBounds 设回true，即只读边不读内容
            newOpts.inJustDecodeBounds = true
            newOpts.inPreferredConfig = Bitmap.Config.RGB_565
            // 获取位图信息，但请注意位图现在为空
            var bitmap = BitmapFactory.decodeFile(imgPath, newOpts)
            newOpts.inJustDecodeBounds = false
            val w = newOpts.outWidth
            val h = newOpts.outHeight

            val max = Math.max(w, h)
            var scare = 1f
            if (max > scareSize) {
                scare = max / scareSize
            }
            newOpts.inSampleSize = scare.toInt()// 设置缩放比例
            // 开始压缩图片，注意此时已经把options.inJustDecodeBounds 设回false了
            return BitmapFactory.decodeFile(imgPath, newOpts)
        }

        /**
         * 设置状态栏全透明
         *
         * @param activity 需要设置的activity
         */
        fun setTransparent(activity: Activity) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                return
            }
            transparentStatusBar(activity)
            setRootView(activity)
        }

        /**
         * 使状态栏透明
         */
        @TargetApi(Build.VERSION_CODES.KITKAT)
        private fun transparentStatusBar(activity: Activity) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                activity.window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
                //需要设置这个flag contentView才能延伸到状态栏
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
                //状态栏覆盖在contentView上面，设置透明使contentView的背景透出来
                activity.window.statusBarColor = Color.TRANSPARENT
            } else {
                //让contentView延伸到状态栏并且设置状态栏颜色透明
                activity.window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            }
        }

        /**
         * 设置根布局参数
         */
        private fun setRootView(activity: Activity) {
            val parent = activity.findViewById<View>(android.R.id.content) as ViewGroup
            var i = 0
            val count = parent.childCount
            while (i < count) {
                val childView = parent.getChildAt(i)
                if (childView is ViewGroup) {
                    childView.setFitsSystemWindows(true)
                    childView.clipToPadding = true
                }
                i++
            }
        }
    }


}
