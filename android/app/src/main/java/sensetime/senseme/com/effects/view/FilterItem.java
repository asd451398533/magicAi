package sensetime.senseme.com.effects.view;

import android.graphics.Bitmap;

public class FilterItem {

    public String name;
    public Bitmap icon;
    public String model;

    public FilterItem(String name, Bitmap icon, String modelName) {
        this.name = name;
        this.icon = icon;
        this.model = modelName;
    }
}
