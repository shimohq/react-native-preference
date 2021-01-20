package im.shimo.react.preference;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import javax.annotation.Nullable;


public class PreferenceModule extends ReactContextBaseJavaModule {

    private BroadcastReceiver sharePreferenceReceiver;
    private Gson gson = new Gson();
    private final String kSHMPreferenceChangedEmitterTag = "SHMPreferenceWhiteListChanged";
    private final String kSHMPreferenceClearEmitterTag = "SHMPreferenceClear";

    public PreferenceModule(ReactApplicationContext context) {
        super(context);
        registerSharePreferenceReceiver();
    }

    public String getName() {
        return "RNPreferenceManager";
    }

    @ReactMethod
    public void set(String jsonStr, Promise promise) {
        getDelegate().setJSPreferenceChangedDataString(jsonStr);
        promise.resolve(getDelegate().getAllPreferences());
    }

    @ReactMethod
    public void clear(Promise promise) {
        getDelegate().clear();
        promise.resolve(getDelegate().getAllPreferences());
    }

    @ReactMethod
    public void getPreferenceForKey(String key, Promise promise) {
        getDelegate().getPreferenceValueForKey(key);
        promise.resolve(getDelegate().getAllPreferences());
    }

    @ReactMethod
    public void setWhiteList(ReadableArray whiteList) {
        getDelegate().whiteList = whiteList.toArrayList();
    }

    @Override
    public Map<String, Object> getConstants() {
        final Map<String, Object> constants = new HashMap<>();
        constants.put("InitialPreferences", getDelegate().getAllPreferences());
        return constants;
    }

    @Override
    public void onCatalystInstanceDestroy() {
        getReactApplicationContext().unregisterReceiver(sharePreferenceReceiver);
    }

    private SharedPreferencesDelegate getDelegate(){
        if (SharedPreferencesDelegate.getInstance()==null){
            SharedPreferencesDelegate.createInstance(getReactApplicationContext());
        }
        return SharedPreferencesDelegate.getInstance();
    }

    private void registerSharePreferenceReceiver() {
        sharePreferenceReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent.getAction().equals(SharedPreferencesDelegate.kSHMPreferenceChangedNotification)) {
                    String msg = intent.getStringExtra("MSG");
                    HashMap<String,String> msgMap = gson.fromJson(msg, HashMap.class);
                    WritableMap map = Arguments.createMap();
                    for (Map.Entry<String, String> entry : msgMap.entrySet()) {
                        map.putString(entry.getKey(),entry.getValue());
                    }

                    sendEvent(
                        getReactApplicationContext(),
                        kSHMPreferenceChangedEmitterTag,
                        map
                    );
                }

                if (intent.getAction().equals(SharedPreferencesDelegate.kSHMPreferenceClearedNotification)) {
                    String key = intent.getStringExtra("MSG");
                    WritableMap map = Arguments.createMap();
                    if (key != null) {
                        map.putString("key", key);
                    }

                    sendEvent(
                        getReactApplicationContext(),
                        kSHMPreferenceClearEmitterTag,
                        map
                    );
                }
            }
        };
        IntentFilter dataIntentFilter = new IntentFilter(SharedPreferencesDelegate.kSHMPreferenceChangedNotification);
        getReactApplicationContext().registerReceiver(sharePreferenceReceiver, dataIntentFilter);
        IntentFilter clearIntentFilter = new IntentFilter(SharedPreferencesDelegate.kSHMPreferenceClearedNotification);
        getReactApplicationContext().registerReceiver(sharePreferenceReceiver, clearIntentFilter);
    }

    private void sendEvent(ReactContext reactContext,
                           String eventName,
                           @Nullable WritableMap params) {
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
    }
}
