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

    final private String mPreferenceKey = "data";
    private SharedPreferences mSharedPreferences;

    public PreferenceModule(ReactApplicationContext context) {
        super(context);
        mSharedPreferences = getReactApplicationContext().getSharedPreferences("react-native-preference", Context.MODE_PRIVATE);
    }

    public String getName() {
        return "RNPreferenceManager";
    }

    @ReactMethod
    public void set(String data, Promise promise) {
        SharedPreferences.Editor editor = getEditor();
        editor.putString(mPreferenceKey, data);
        editor.apply();
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void clear(Promise promise) {
        SharedPreferences.Editor editor = getEditor();
        editor.remove(mPreferenceKey);
        editor.apply();
        promise.resolve(getPreferences());
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("InitialPreferences", getPreferences());
        return constants;
    }

    private String getPreferences() {
        return mSharedPreferences.getString(mPreferenceKey, "{}");
    }

    private SharedPreferences.Editor getEditor() {
        return mSharedPreferences.edit();
    }

    @Override
    public void onCatalystInstanceDestroy() {
        //mSharedPreferences.unregisterOnSharedPreferenceChangeListener(mListener);
    }

}
