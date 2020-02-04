package sensetime.senseme.com.effects

import android.content.Context
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.example.gengmei_app_face.R

/**
 * @author lsy
 * @date   2019-12-24
 */
class TestAdapter(val context: Context, val list: ArrayList<TestBean>
                  , val listener: TextClickListener) : RecyclerView.Adapter<TestAdapter.TestHolder>() {

    var nowText = "";

    override fun onCreateViewHolder(p0: ViewGroup, p1: Int): TestHolder {
        val inflate = LayoutInflater.from(context).inflate(R.layout.test_item, p0, false)
        return TestHolder(inflate)
    }

    override fun getItemCount(): Int {
        return list.size
    }

    override fun onBindViewHolder(p0: TestHolder, p1: Int) {
        p0.text.setText(list[p1].text)
        p0.view.setOnClickListener {
            for (i in 0..list.size - 1) {
                if (i == p1) {
                    listener.onClick(list[i].list)
                    list[i].check = true;
                } else {
                    list[i].check = false;
                }
            }
            notifyDataSetChanged()
        }
        if (list[p1].check) {
            nowText = list[p1].text
            p0.image.visibility = View.VISIBLE
        } else {
            p0.image.visibility = View.INVISIBLE
        }
    }

    class TestHolder(val view: View) : RecyclerView.ViewHolder(view) {
        val image: ImageView
        val text: TextView

        init {
            image = view.findViewById(R.id.check)
            text = view.findViewById(R.id.text)
        }
    }

    interface TextClickListener {
        fun onClick(data: ArrayList<Float>)
    }

}
