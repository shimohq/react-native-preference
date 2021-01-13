package im.shimo.react.preference;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;

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
        getDelegate().set(mPreferenceKey,data);
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void clear(Promise promise) {
        getDelegate().remove(mPreferenceKey);
        promise.resolve(getPreferences());
    }

    @ReactMethod
    public void getPreferenceForKey(String key, Promise promise) {
        //getDelegate();
    }

    @ReactMethod
    public void setWhiteList(ReadableArray whiteList) {
        getDelegate().whiteList = whiteList.toArrayList();
    }



    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("InitialPreferences", getPreferences());
        return constants;
    }

    private String getPreferences() {
        return getDelegate().get(mPreferenceKey, "{}");
    }

    private SharedPreferencesDelegate getDelegate(){
        if (SharedPreferencesDelegate.getInstance()==null){
            SharedPreferencesDelegate.createInstance(getReactApplicationContext());
        }
        return SharedPreferencesDelegate.getInstance();
    }



    @Override
    public void onCatalystInstanceDestroy() {
        //mSharedPreferences.unregisterOnSharedPreferenceChangeListener(mListener);
    }



}
