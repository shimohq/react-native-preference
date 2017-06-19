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
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;


public class PreferenceModule extends ReactContextBaseJavaModule {

    // Must keep a strong reference to the listener,
    // or it will be susceptible to garbage collection.
    private SharedPreferences.OnSharedPreferenceChangeListener mListener;

    private SharedPreferences mSharedPreferences;

    public PreferenceModule(ReactApplicationContext context) {
        super(context);

        mSharedPreferences = getReactApplicationContext().getSharedPreferences(context.getPackageName(), Context.MODE_PRIVATE);
        mListener = new SharedPreferences.OnSharedPreferenceChangeListener() {
            public void onSharedPreferenceChanged(SharedPreferences prefs, String key) {
                getReactApplicationContext()
                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                        .emit("sync", getPreferences());
            }
        };

        mSharedPreferences.registerOnSharedPreferenceChangeListener(mListener);
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
        Map<String, ?> allEntries = mSharedPreferences.getAll();
        for (Map.Entry<String, ?> entry : allEntries.entrySet()) {
            editor.remove(entry.getKey());
        }
        editor.commit();
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void clear(String key, Promise promise) {
        SharedPreferences.Editor editor = getEditor();
        editor.remove(key);
        editor.commit();
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
        Map<String, ?> allEntries = mSharedPreferences.getAll();
        for (Map.Entry<String, ?> entry : allEntries.entrySet()) {
            result.putString(entry.getKey(), entry.getValue().toString());
        }

        return result;
    }

    private SharedPreferences.Editor getEditor() {
        return mSharedPreferences.edit();
    }

    @Override
    public void onCatalystInstanceDestroy() {
        mSharedPreferences.unregisterOnSharedPreferenceChangeListener(mListener);
    }

}
