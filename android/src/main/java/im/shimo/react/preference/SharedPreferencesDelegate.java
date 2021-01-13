package im.shimo.react.preference;

import android.content.Context;
import android.content.SharedPreferences;

import java.util.ArrayList;

/**
 * Created by jiang on 2019-12-26
 */

public class SharedPreferencesDelegate {

    protected static volatile SharedPreferencesDelegate INSTANCE;

    public static SharedPreferencesDelegate getInstance() {
        return INSTANCE;
    }

    protected SharedPreferences mSharedPreferences;

    public static ArrayList<Object> whiteList;

    protected SharedPreferencesDelegate(Context context) {
        mSharedPreferences = context.getApplicationContext()
                .getSharedPreferences("react-native-preference", Context.MODE_PRIVATE);
    }

    private SharedPreferences.Editor getEditor() {
        return mSharedPreferences.edit();
    }


    public void set(String key, String data) {
        SharedPreferences.Editor editor = getEditor();
        editor.putString(key, data);
        editor.apply();
    }

    public String get(String key, String defValue) {
        return mSharedPreferences.getString(key, defValue);
    }


    public void remove(String key) {
        SharedPreferences.Editor editor = getEditor();
        editor.remove(key);
        editor.apply();
    }

    public void register(SharedPreferences.OnSharedPreferenceChangeListener listener) {
        mSharedPreferences.registerOnSharedPreferenceChangeListener(listener);
    }

    public void unregister(SharedPreferences.OnSharedPreferenceChangeListener listener) {
        mSharedPreferences.unregisterOnSharedPreferenceChangeListener(listener);
    }

    public static void createInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (SharedPreferencesDelegate.class) {
                if (INSTANCE == null) {
                    INSTANCE = new SharedPreferencesDelegate(context);
                }
            }
        }
    }


    public boolean getBoolean(String key, boolean defValue) {
        return mSharedPreferences.getBoolean(key, defValue);
    }

    public void putBoolean(String key, boolean value) {
        getEditor().putBoolean(key, value);
    }
}

