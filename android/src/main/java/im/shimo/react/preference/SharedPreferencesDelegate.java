package im.shimo.react.preference;

import com.google.gson.Gson;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jiang on 2019-12-26
 */

public class SharedPreferencesDelegate {

    protected static volatile SharedPreferencesDelegate INSTANCE;

    public static final String kSHMPreferenceChangedNotification = "SHMPreference_WhiteList_Notification";
    public static final String kSHMPreferenceClearedNotification = "SHMPreference_Clear_Notification";
    private final String mPreferenceKey = "data";

    public static SharedPreferencesDelegate getInstance() {
        return INSTANCE;
    }

    protected SharedPreferences mSharedPreferences;

    private Gson gson = new Gson();
    private static final String TAG = SharedPreferencesDelegate.class.getSimpleName();
    private Context mContext;

    public ArrayList<Object> whiteList;
    public HashMap<String, Object> singlePreference;

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
        return (String)(INSTANCE.singlePreference.get(key));
    }

    public void setJSPreferenceChangedDataString(String jsonStr) {
        Map<String,Object> mapChanged = gson.fromJson(jsonStr,Map.class);
        for (String key : mapChanged.keySet()) {
            Object value = mapChanged.get(key);
            setPreferenceItem(value, key);
        }
    }

    public void clear() {
        if (INSTANCE.singlePreference.keySet().size() == 0) return;

        //Broadcast
        Intent intent = new Intent(kSHMPreferenceClearedNotification);
        INSTANCE.mContext.sendBroadcast(intent);

        //clear
        INSTANCE.singlePreference = new HashMap<>();
        SharedPreferences.Editor editor = getEditor();
        editor.remove(mPreferenceKey);
        editor.apply();
    }

    public void clearValueForKey(String key) {
        if (!INSTANCE.singlePreference.keySet().contains(key)) return;

        //clear
        INSTANCE.singlePreference.remove(key);
        SharedPreferences.Editor editor = getEditor();
        editor.putString(mPreferenceKey, gson.toJson(INSTANCE.singlePreference,HashMap.class));
        editor.apply();

        if (INSTANCE.whiteList.contains(key)) {
            //Broadcast
            Intent intent = new Intent(kSHMPreferenceClearedNotification);
            intent.putExtra("MSG", key);
            INSTANCE.mContext.sendBroadcast(intent);
        }
    }


    public void setPreferenceItem(Object value, String key) {
        if (value == null) { // value is null , clear key
            clearValueForKey(key);
            return;
        }

        HashMap<String,Object> tmpMap = new HashMap<>();
        tmpMap.putAll(INSTANCE.singlePreference);
        tmpMap.put(key,value);

        if (INSTANCE.whiteList.size() == 0) {
            Log.w(TAG, "RNPreference - white list is null !");
        }

        // Diff
        if (!value.equals(INSTANCE.singlePreference.get(key))) {
            if (INSTANCE.whiteList.contains(key)) {
                // in white list
                Log.d(TAG, String.format( "RNPreference Changed :  {%s} {%s}",key,value));
                // Broadcast
                Intent intent = new Intent(kSHMPreferenceChangedNotification);
                HashMap<String, Object> msgMap = new HashMap<String, Object>();
                msgMap.put(key,value);
                intent.putExtra("MSG", gson.toJson(msgMap,HashMap.class));
                INSTANCE.mContext.sendBroadcast(intent);
            }
        }

        // set
        INSTANCE.singlePreference = tmpMap;
        SharedPreferences.Editor editor = getEditor();
        editor.putString(mPreferenceKey, gson.toJson(tmpMap,HashMap.class));
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
                    INSTANCE.singlePreference = INSTANCE.gson.fromJson(INSTANCE.getAllPreferences(), HashMap.class);
                    INSTANCE.mContext = context;
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

