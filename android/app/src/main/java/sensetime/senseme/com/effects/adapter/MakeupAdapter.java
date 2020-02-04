package sensetime.senseme.com.effects.adapter;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.ViewHolder;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.example.gengmei_app_face.R;

import java.util.List;

import sensetime.senseme.com.effects.view.MakeupItem;
import sensetime.senseme.com.effects.view.RoundImageView;

public class MakeupAdapter extends RecyclerView.Adapter {

    List<MakeupItem> mMakeupList;
    private View.OnClickListener mOnClickMakeupListener;
    private int mSelectedPosition = 0;
    Context mContext;

    public MakeupAdapter(List<MakeupItem> list, Context context) {
        mMakeupList = list;
        mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.makeup_item, null);
        return new MakeupViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        final MakeupViewHolder viewHolder = (MakeupViewHolder) holder;
        viewHolder.imageView.setNeedBorder(false);
        viewHolder.imageView.setImageBitmap(mMakeupList.get(position).icon);
        viewHolder.textView.setText(mMakeupList.get(position).name);
        viewHolder.textView.setTextColor(Color.parseColor("#ffffff"));

        holder.itemView.setSelected(mSelectedPosition == position);

        if(mSelectedPosition == position){
            viewHolder.imageView.setNeedBorder(true);
        }

        if(mOnClickMakeupListener != null) {
            holder.itemView.setTag(position);

            holder.itemView.setOnClickListener(mOnClickMakeupListener);
//            holder.itemView.setSelected(mSelectedPosition == position);
        }
    }

    public void setClickMakeupListener(View.OnClickListener listener) {
        mOnClickMakeupListener = listener;
    }

    @Override
    public int getItemCount() {
        return mMakeupList.size();
    }

    static class MakeupViewHolder extends ViewHolder {

        View view;
        RoundImageView imageView;
        TextView textView;

        public MakeupViewHolder(View itemView) {
            super(itemView);
            view = itemView;
            imageView = (RoundImageView) itemView.findViewById(R.id.iv_makeup_image);
            textView = (TextView) itemView.findViewById(R.id.makeup_text);
        }
    }

    public void setSelectedPosition(int position){
        mSelectedPosition = position;
    }
}
