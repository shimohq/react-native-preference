package im.shimo.react.preference;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import java.util.HashMap;
import java.util.Map;


public class PreferenceModule extends ReactContextBaseJavaModule {

    private final String mPreferenceKey = "data";

    public PreferenceModule(ReactApplicationContext context) {
        super(context);
    }

    public String getName() {
        return "RNPreferenceManager";
    }

    @ReactMethod
    public void set(String data, Promise promise) {
        SharedPreferencesDelegate.getInstance().set(mPreferenceKey,data);
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void clear(Promise promise) {
        SharedPreferencesDelegate.getInstance().remove(mPreferenceKey);
        promise.resolve(getPreferences());
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("InitialPreferences", getPreferences());
        return constants;
    }

    private String getPreferences() {
        return SharedPreferencesDelegate.getInstance().get(mPreferenceKey, "{}");
    }



    @Override
    public void onCatalystInstanceDestroy() {
        //mSharedPreferences.unregisterOnSharedPreferenceChangeListener(mListener);
    }



}
