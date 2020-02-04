package sensetime.senseme.com.effects.adapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.ViewHolder;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.example.gengmei_app_face.R;

import java.util.ArrayList;

import sensetime.senseme.com.effects.view.StickerItem;

public class NativeStickerAdapter extends RecyclerView.Adapter {

    ArrayList<StickerItem> mStickerList;
    private View.OnClickListener mOnClickStickerListener;
    private int mSelectedPosition = 0;
    Context mContext;

    public NativeStickerAdapter(ArrayList<StickerItem> list, Context context) {
        mStickerList = list;
        mContext = context;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.native_sticker_item, null);
        return new FilterViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, final int position) {
        final FilterViewHolder viewHolder = (FilterViewHolder) holder;
        viewHolder.imageView.setImageBitmap(mStickerList.get(position).icon);
        holder.itemView.setSelected(mSelectedPosition == position);
        if (mOnClickStickerListener != null) {
            holder.itemView.setTag(position);
            holder.itemView.setOnClickListener(mOnClickStickerListener);

            holder.itemView.setSelected(mSelectedPosition == position);
        }
    }

    public void setClickStickerListener(View.OnClickListener listener) {
        mOnClickStickerListener = listener;
    }

    @Override
    public int getItemCount() {
        return mStickerList.size();
    }

    static class FilterViewHolder extends ViewHolder {

        View view;
        ImageView imageView;

        public FilterViewHolder(View itemView) {
            super(itemView);
            view = itemView;
            imageView = (ImageView) itemView.findViewById(R.id.icon);
        }
    }

    public void setSelectedPosition(int position) {
        mSelectedPosition = position;
    }
}
