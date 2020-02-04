package com.example.gengmei_app_face.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

import com.example.gengmei_flutter_plugin.utils.DimensionUtils;

import java.util.List;

import zeusees.tracking.Face;

public class CameraHideView extends View {

    private Paint backPaint;
    private Rect backRect = new Rect();
    private Paint textPaint = new Paint();
    private Paint pathPaint = new Paint();
    private Path path1 = new Path();
    private Path path2 = new Path();
    private List<Point> pointList;
    private Rect rect = new Rect();
    private RectF rectF = new RectF();
    private boolean isDected = false;
    private Context context;


    public CameraHideView(Context context) {
        this(context, null);
    }

    public CameraHideView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CameraHideView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.context = context;
        initPaint();
    }

    private float headWidth;
    private float headHeight;
    private float xWidth;


    private void initPaint() {
        xWidth = DimensionUtils.dp2Px(context, 5);
        headWidth = DimensionUtils.dp2Px(context, 100);
        headHeight = DimensionUtils.dp2Px(context, 200);
        backPaint = new Paint();
        backPaint.setColor(0x77000000);
        backPaint.setAntiAlias(true);
        backPaint.setStrokeJoin(Paint.Join.ROUND);

        textPaint.setAntiAlias(true);
        textPaint.setTextSize(DimensionUtils.dp2Px(context, 15));
        textPaint.setColor(Color.WHITE);

        pathPaint.setAntiAlias(true);
        pathPaint.setStrokeWidth(DimensionUtils.dp2Px(context, 2));
        pathPaint.setColor(Color.RED);
        pathPaint.setStyle(Paint.Style.STROKE);


    }


    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        rectF.set(w / 2 - headWidth / 2, h / 2 - headWidth / 2 - DimensionUtils.dp2Px(context,20), w / 2 + headWidth / 2, h / 2 + headWidth / 2 - DimensionUtils.dp2Px(context,50));
        path2.moveTo(w / 2, h / 2);
        path2.addArc(rectF, 0, -180);
//        path2.rLineTo(DimensionUtils.dp2Px(10), DimensionUtils.dp2Px(80));
        path2.rCubicTo(0, 0, DimensionUtils.dp2Px(context,2), DimensionUtils.dp2Px(context,40), xWidth, DimensionUtils.dp2Px(context,80));
        path2.rCubicTo(0, 0, (headWidth - xWidth * 2) / 2, headWidth / 2 + xWidth * 2 + DimensionUtils.dp2Px(context,30), (headWidth - xWidth * 2), 0);
        path2.rCubicTo(0, 0, DimensionUtils.dp2Px(context,3), -DimensionUtils.dp2Px(context,40), DimensionUtils.dp2Px(context,5), -DimensionUtils.dp2Px(context,80));

        path1.addRect(0, 0, getMeasuredWidth(), getMeasuredHeight(), Path.Direction.CCW);
        path1.op(path2, Path.Op.DIFFERENCE);
    }

    private String text = "正在启动人脸框";

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
//        canvas.drawPath(path1, backPaint);
        if (!TextUtils.isEmpty(text)) {
            canvas.drawText(text, getMeasuredWidth() / 2 - textPaint.measureText(text) / 2, getMeasuredHeight() / 2 + DimensionUtils.dp2Px(context,130), textPaint);
        }
        if (!isDected) {
            return;
        }

        if (pointList != null && !pointList.isEmpty()) {
            for (Point point : pointList) {
                canvas.drawPoint(point.x, point.y, pathPaint);
            }
        }
        if (rect != null) {
            canvas.drawRect(rect, pathPaint);
        }
    }


//    public void setData(List<Face> faceList) {
//        if (faceList == null) {
//            rect = null;
//            pointList = null;
//            text = "没有检测到人脸";
//            textPaint.setColor(Color.RED);
//            invalidate();
//            return;
//        }
//        if (faceList.size() == 1) {
//            Face face = faceList.get(0);
//            if (face.rect.right == 0 && face.rect.bottom == 0) {
//                rect = null;
//                pointList = null;
//                text = "没有检测到人脸";
//                textPaint.setColor(Color.RED);
//            } else if (face.rect.left < DimensionUtils.dp2Px(20)
//                    || face.rect.right > getMeasuredWidth() - DimensionUtils.dp2Px(20)
//                    || face.rect.bottom > getMeasuredHeight() - DimensionUtils.dp2Px(20)
//                    || face.rect.top < DimensionUtils.dp2Px(20)
//            ) {
//                text = "这个位置有点偏哦";
//                textPaint.setColor(Color.RED);
//            } else {
//                text = "这个位置不错";
//                textPaint.setColor(Color.WHITE);
//            }
//            rect=face.rect;
//            pointList=face.list;
//        } else {
//            rect = null;
//            pointList = null;
//            text = "暂时不支持多个人脸";
//            textPaint.setColor(Color.RED);
//        }
//        invalidate();
//    }

    public void setData(List<Face> faceActions, List<Point> pointList, float scareX, float scareY, int height, boolean isFont) {
        if (faceActions == null || faceActions.isEmpty()) {
            isDected = false;
            text = "没有检测到人脸";
            textPaint.setColor(Color.RED);
            invalidate();
            return;
        }
        if (faceActions.size() == 1) {
            isDected = true;
            Face face = faceActions.get(0);
            if (rect == null) {
                rect = new Rect();
            }
            if (isFont) {
                rect.set((int) (face.left * scareY), (int) (face.top * scareY), (int) (face.right * scareY), (int) (face.bottom * scareY));
            } else {
                rect.set((int) (height * scareY - face.left * scareY), (int) (face.top * scareY), (int) (height * scareY - face.right * scareY), (int) (face.bottom * scareY));
            }
            Log.e("lsy", " " + face.left + "  " + face.right + "  " + face.bottom);
            this.pointList = pointList;
            text = "这个位置不错";
            textPaint.setColor(Color.WHITE);
        } else {
            isDected = false;
            text = "暂时不支持多个人脸";
            textPaint.setColor(Color.RED);
        }
        invalidate();
    }
}
