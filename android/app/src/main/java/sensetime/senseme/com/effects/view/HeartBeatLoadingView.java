package sensetime.senseme.com.effects.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.util.AttributeSet;
import android.view.View;

import com.example.gengmei_app_face.R;

import java.util.Timer;
import java.util.TimerTask;

import static com.example.gengmei_app_face.util.DeviceUtils.getHeight;
import static com.example.gengmei_app_face.util.DeviceUtils.getWidth;

/**
 * @author lsy
 * @date 2020-01-02
 */
public class HeartBeatLoadingView extends View {

    private Paint bacPaint;

    private Paint whitePaint;

    private Paint redPaint;

    private float current = 0;

    public HeartBeatLoadingView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    private void initView() {
        bacPaint = new Paint();
        bacPaint.setColor(Color.parseColor("#555555"));
        bacPaint.setAntiAlias(true);
        bacPaint.setStrokeWidth(1);

        whitePaint = new Paint();
        whitePaint.setColor(Color.parseColor("#ffffff"));
        whitePaint.setAntiAlias(true);
        whitePaint.setStrokeWidth(1);

        redPaint = new Paint();
        redPaint.setColor(Color.RED);
        redPaint.setAntiAlias(true);
        redPaint.setStrokeWidth(1);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        // 通过测量规则获得宽和高
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = MeasureSpec.getSize(heightMeasureSpec);

        int len = Math.min(width, height);

        setMeasuredDimension(len, len);

    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        drawBac(canvas);
    }

    private void drawBac(Canvas canvas) {

        RectF rectF = new RectF(0, 0, getWidth(), getHeight());
        canvas.drawRect(rectF, whitePaint);

        RectF rectF1 = new RectF(current - getWidth() * (float) 0.3, 0, current, getHeight());
        canvas.drawRect(rectF1, redPaint);

        Path path = new Path();
        path.moveTo(0, (float) getHeight() / 2 - (getHeight() * (float) 0.01));
        path.lineTo(getWidth() * (float) 0.3 - getWidth() * (float) 0.01, (float) getHeight() / 2 - (getHeight() * (float) 0.01));
        path.lineTo(getWidth() * (float) 0.4, (float) getHeight() / 2 - (getHeight() * (float) 0.2) - (getHeight() * (float) 0.02));//上30
//        path.lineTo(getWidth() * (float)0.4 + getWidth() * (float)0.01,(float)getHeight()/2 - (getHeight() * (float)0.2));
        path.lineTo(getWidth() * (float) 0.6, (float) getHeight() / 2 - (getHeight() * (float) 0.02) + (getHeight() * (float) 0.2));//下30
        path.lineTo(getWidth() * (float) 0.7 - getWidth() * (float) 0.01, (float) getHeight() / 2 - (getHeight() * (float) 0.01));
        path.lineTo((float) getWidth(), (float) getHeight() / 2 - (getHeight() * (float) 0.01));
        path.lineTo((float) getWidth(), (float) getHeight() / 2 + (getHeight() * (float) 0.01));
        path.lineTo(getWidth() * (float) 0.7 + getWidth() * (float) 0.01, (float) getHeight() / 2 + (getHeight() * (float) 0.01));
        path.lineTo(getWidth() * (float) 0.6, (float) getHeight() / 2 + (getHeight() * (float) 0.03) + (getHeight() * (float) 0.2));
//        path.lineTo(getWidth() * (float)0.6 - getWidth() * (float)0.01,(float)getHeight()/2 + (getHeight() * (float)0.01) + (getHeight() * (float)0.2));
        path.lineTo(getWidth() * (float) 0.4, (float) getHeight() / 2 + (getHeight() * (float) 0.02) - (getHeight() * (float) 0.2));
        path.lineTo(getWidth() * (float) 0.3 + getWidth() * (float) 0.01, (float) getHeight() / 2 + (getHeight() * (float) 0.01));
        path.lineTo(0, (float) getHeight() / 2 + (getHeight() * (float) 0.01));
        path.close();

        canvas.clipPath(path, Region.Op.DIFFERENCE);

        canvas.drawRect(rectF, whitePaint);
    }


    private Timer timer;

    public void cancel() {
        timer.cancel();
    }

    public void run() {
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                current += (float) 0.5;
                if (current > getWidth() * (1.3)) {
                    current = 0 - getWidth() * (float) 0.3;
                }
                postInvalidate();
            }
        }, 200, 1);
    }


}
