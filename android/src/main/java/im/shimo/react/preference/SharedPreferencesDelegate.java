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

    public static String kSHMPreferenceChangedNotification = "SHMPreferenceWhiteListChanged";

    private final String mPreferenceKey = "data";

    public static SharedPreferencesDelegate getInstance() {
        return INSTANCE;
    }

    protected SharedPreferences mSharedPreferences;

    private Gson gson = new Gson();
    private static final String TAG = SharedPreferencesDelegate.class.getSimpleName();
    private Context mContext;

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
        HashMap<String, String> tmpMap = new HashMap<String, String>();
        tmpMap.putAll(INSTANCE.singlePreference);
        tmpMap.put(key,value);
        setPreferenceData(gson.toJson(tmpMap,HashMap.class));
    }

    public void setPreferenceData(String data) {
        Map<String, String> obj = gson.fromJson(data, Map.class);
        if (obj == null) {
            Log.w(TAG, "err: setPreferenceData - wrong data type!");
            return;
        }

        if (INSTANCE.whiteList.size() == 0) {
            Log.w(TAG, "RNPreference - white list is null !");
        }

        // Diff
        Map<String, String> mapNew = obj;
        Map<String, String> mapOld = INSTANCE.singlePreference;

        // set data
        INSTANCE.singlePreference = obj;
        SharedPreferences.Editor editor = getEditor();
        editor.putString(mPreferenceKey, data);
        editor.apply();

        // 1. map is equal
        if (!mapNew.equals(mapOld)) {
            if (data.equals("{}") && mapOld != null) {
                Intent intent = new Intent(kSHMPreferenceChangedNotification);
                intent.putExtra("MSG", "{}");
                INSTANCE.mContext.sendBroadcast(intent);

                return;
            }

            //2. whitelist
            for (int i = 0; i < INSTANCE.whiteList.size(); i ++) {
                String key = (String)INSTANCE.whiteList.get(i);
                String strNew = mapNew.get(key);
                String strOld = mapOld.get(key);
                if (strNew == null || strNew.length() == 0) return;

                if (!strNew.equals(strOld)) {
                    //3. data changed, send msg to JS
                    Map<String, String> item = new HashMap<>();
                    item.put(key,strNew);
                    Log.d(TAG, String.format( "RNPreference (key) {%s} , Changed : {%s}",key,strNew));
                    Intent intent = new Intent(kSHMPreferenceChangedNotification);
                    Map<String, String> msgMap = new HashMap<String, String>();
                    msgMap.put(key,strNew);
                    intent.putExtra("MSG", gson.toJson(msgMap,Map.class));
                    INSTANCE.mContext.sendBroadcast(intent);
                }
            }
        }
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
                    INSTANCE.singlePreference = INSTANCE.gson.fromJson(INSTANCE.getAllPreferences(), Map.class);
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

