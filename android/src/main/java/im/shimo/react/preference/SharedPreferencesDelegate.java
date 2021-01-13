package im.shimo.react.preference;

import android.content.Context;
import android.content.SharedPreferences;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jiang on 2019-12-26
 */



public class SharedPreferencesDelegate {

    protected static volatile SharedPreferencesDelegate INSTANCE;

    private final String mPreferenceKey = "data";

    public static SharedPreferencesDelegate getInstance() {
        return INSTANCE;
    }

    protected SharedPreferences mSharedPreferences;

    public ArrayList<Object> whiteList;
    public Map<String, String> singlePreference;


    protected SharedPreferencesDelegate(Context context) {
        mSharedPreferences = context.getApplicationContext()
                .getSharedPreferences("react-native-preference", Context.MODE_PRIVATE);
    }

    private SharedPreferences.Editor getEditor() {
        return mSharedPreferences.edit();
    }

    public String getAllPreferences() {
        return mSharedPreferences.getString(mPreferenceKey, "{}");
    }

    public String getPreferenceValueForKey(String key) {
        return INSTANCE.singlePreference.get(key);
    }

    public void setPreferenceItem(String value, String key) {
        INSTANCE.singlePreference.put(key,value);
//        NSMutableDictionary *tmpMap = [self.singlePerference mutableCopy];
//        [tmpMap setObject:value forKey:key];
//        [self setPreferenceData:RCTJSONStringify(tmpMap, nil)];
    }

    public void setPreferenceData(String data) {


        SharedPreferences.Editor editor = getEditor();
        editor.putString(mPreferenceKey, data);
        editor.apply();
    }


    public void remove() {
        SharedPreferences.Editor editor = getEditor();
        editor.remove(mPreferenceKey);
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
                    //INSTANCE.singlePerference = RCTJSONParse([RNPreferenceSingleton getAllPreferences], nil);
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

