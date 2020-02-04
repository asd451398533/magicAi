package sensetime.senseme.com.effects.adapter;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.gengmei_app_face.R;

import java.util.ArrayList;

import sensetime.senseme.com.effects.view.BeautyOptionsItem;

public class BeautyOptionsAdapter extends RecyclerView.Adapter{
    ArrayList<BeautyOptionsItem> mBeautyOptions;
    private View.OnClickListener mOnClickBeautyListener;
    private int mSelectedPosition = 0;
    Context mContext;

    public BeautyOptionsAdapter(ArrayList<BeautyOptionsItem> list, Context context) {
        mBeautyOptions = list;
        mContext = context;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.beauty_options_item, null);
        return new BeautyOptionsAdapter.FilterViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, final int position) {
        final BeautyOptionsAdapter.FilterViewHolder viewHolder = (BeautyOptionsAdapter.FilterViewHolder) holder;
        viewHolder.mName.setText(mBeautyOptions.get(position).name);
        viewHolder.mName.setTextColor(Color.parseColor("#ffffff"));
        viewHolder.mFlag.setVisibility(View.INVISIBLE);
        holder.itemView.setSelected(mSelectedPosition == position);
        if(mSelectedPosition == position){
            viewHolder.mFlag.setVisibility(View.VISIBLE);
            viewHolder.mName.setTextColor(Color.parseColor("#bc47ff"));
        }
        if (mOnClickBeautyListener != null) {
            holder.itemView.setTag(position);
            holder.itemView.setOnClickListener(mOnClickBeautyListener);
            holder.itemView.setSelected(mSelectedPosition == position);
        }
    }

    public void setClickBeautyListener(View.OnClickListener listener) {
        mOnClickBeautyListener = listener;
    }

    @Override
    public int getItemCount() {
        return mBeautyOptions.size();
    }

    static class FilterViewHolder extends RecyclerView.ViewHolder {

        View view;
        TextView mName;
        ImageView mFlag;

        public FilterViewHolder(View itemView) {
            super(itemView);
            view = itemView;
            mName = (TextView) itemView.findViewById(R.id.iv_beauty_options);
            mFlag = (ImageView) itemView.findViewById(R.id.iv_select_flag);
        }
    }

    public void setSelectedPosition(int position) {
        mSelectedPosition = position;

    }
}
