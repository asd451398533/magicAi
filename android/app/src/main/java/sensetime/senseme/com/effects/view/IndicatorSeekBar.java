package sensetime.senseme.com.effects.view;

import android.content.Context;
import android.graphics.Rect;
import android.support.annotation.Nullable;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.example.gengmei_app_face.R;


public class IndicatorSeekBar extends LinearLayout {

    TextView textView;
    SeekBar seekBar;
    TextPaint paint;
    int mTextWidth;
    int seekBarLeftMargin;
    Rect textBounds = new Rect();

    public IndicatorSeekBar(Context context) {
        this(context, null);
    }

    public IndicatorSeekBar(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public IndicatorSeekBar(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context){
        final LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        inflater.inflate(R.layout.view_indicator_seekbar, this);
        textView = (TextView)findViewById(R.id.isb_progress);
        seekBar = (SeekBar) findViewById(R.id.isb_seekbar);
        LinearLayout.LayoutParams lp = (LayoutParams) textView.getLayoutParams();
        seekBarLeftMargin = lp.leftMargin;
        paint = textView.getPaint();
    }

    public void updateTextview(int progress){
        Rect bounds = seekBar.getProgressDrawable().getBounds();
        LinearLayout.LayoutParams lp = (LayoutParams) textView.getLayoutParams();
        textView.setText(progress + "");
        paint.getTextBounds("0", 0, 1, textBounds);
        mTextWidth = textBounds.width();
        lp.leftMargin = (bounds.width() * seekBar.getProgress() / seekBar.getMax()) + seekBarLeftMargin + mTextWidth;
        textView.setLayoutParams(lp);
    }

    public void setOnSeekBarChangeListener(SeekBar.OnSeekBarChangeListener listener){
        seekBar.setOnSeekBarChangeListener(listener);
    }

    public SeekBar getSeekBar() {
        return seekBar;
    }
}
