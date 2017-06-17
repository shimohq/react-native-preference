package im.shimo.react.preference;

import android.content.Context;
import android.content.SharedPreferences;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;


public class PreferenceModule extends ReactContextBaseJavaModule {

    private String mPackageName;

    public PreferenceModule(ReactApplicationContext context) {
        super(context);
        mPackageName = context.getPackageName();
    }

    public String getName() {
        return "RNPreferenceManager";
    }

    @ReactMethod
    public void set(ReadableMap data, Promise promise) {
        SharedPreferences.Editor editor = getEditor();
        ReadableMapKeySetIterator iterator = data.keySetIterator();
        while(iterator.hasNextKey()) {
            String key = iterator.nextKey();
            editor.putString(key, data.getString(key)).commit();
        }
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void clearAll(Promise promise) {
        SharedPreferences.Editor editor = getEditor();
        Map<String, ?> allEntries = getSharedPreferences().getAll();
        for (Map.Entry<String, ?> entry : allEntries.entrySet()) {
            editor.remove(entry.getKey());
        }
        editor.commit();
        promise.resolve(getPreferences());
    }


    @ReactMethod
    public void sync(Promise promise) {
        promise.resolve(getPreferences());
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("InitialPreferences", getPreferences());
        return constants;
    }

    private ReadableMap getPreferences() {
        WritableMap result = Arguments.createMap();
        Map<String, ?> allEntries = getSharedPreferences().getAll();
        for (Map.Entry<String, ?> entry : allEntries.entrySet()) {
            result.putString(entry.getKey(), entry.getValue().toString());
        }

        return result;
    }

    private SharedPreferences getSharedPreferences() {
        return getReactApplicationContext().getSharedPreferences(mPackageName, Context.MODE_PRIVATE);
    }

    private SharedPreferences.Editor getEditor() {
        return getSharedPreferences().edit();
    }
}
