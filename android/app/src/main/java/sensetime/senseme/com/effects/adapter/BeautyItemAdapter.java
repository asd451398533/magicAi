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

import sensetime.senseme.com.effects.view.BeautyItem;

public class BeautyItemAdapter extends RecyclerView.Adapter{

    ArrayList<BeautyItem> mBeautyItem;
    private View.OnClickListener mOnClickBeautyItemListener;
    private int mSelectedPosition = 0;
    Context mContext;

    public BeautyItemAdapter(Context context, ArrayList<BeautyItem> list){
        mContext = context;
        mBeautyItem = list;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.beauty_item, null);
        return new BeautyItemViewHolder(view);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        final BeautyItemAdapter.BeautyItemViewHolder viewHolder = (BeautyItemAdapter.BeautyItemViewHolder) holder;
        viewHolder.mName.setText(mBeautyItem.get(position).getText());
        viewHolder.mSubscription.setText(mBeautyItem.get(position).getProgress() + "");
        viewHolder.mName.setTextColor(Color.parseColor("#ffffff"));
        viewHolder.mSubscription.setTextColor(Color.parseColor("#ffffff"));
        viewHolder.mImage.setImageBitmap(mBeautyItem.get(position).getUnselectedtIcon());
        holder.itemView.setSelected(mSelectedPosition == position);
        if(mSelectedPosition == position){
            viewHolder.mSubscription.setTextColor(Color.parseColor("#bc47ff"));
            viewHolder.mName.setTextColor(Color.parseColor("#bc47ff"));
            viewHolder.mImage.setImageBitmap(mBeautyItem.get(position).getSelectedIcon());
        }
        if (mOnClickBeautyItemListener != null) {
            holder.itemView.setTag(position);
            holder.itemView.setOnClickListener(mOnClickBeautyItemListener);
            holder.itemView.setSelected(mSelectedPosition == position);

        }
    }

    @Override
    public int getItemCount() {
        return mBeautyItem.size();
    }

    public void setSelectedPosition(int position) {
        mSelectedPosition = position;
    }

    public void setClickBeautyListener(View.OnClickListener listener) {
        mOnClickBeautyItemListener = listener;
    }

    static class BeautyItemViewHolder extends RecyclerView.ViewHolder {

        View view;
        ImageView mImage;
        TextView mName;
        TextView mSubscription;

        public BeautyItemViewHolder(View itemView) {
            super(itemView);
            view = itemView;
            mName = (TextView) itemView.findViewById(R.id.beauty_item_description);
            mSubscription = (TextView) itemView.findViewById(R.id.beauty_item_subscription);
            mImage = (ImageView) itemView.findViewById(R.id.beauty_item_iv);
        }
    }
}
