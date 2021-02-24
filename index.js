import {NativeModules, NativeEventEmitter} from 'react-native';

const { RNPreferenceManager } = NativeModules;
const eventEmitter = new NativeEventEmitter(RNPreferenceManager);
const listeners = new Set();

eventEmitter.addListener('SHMPreferenceWhiteListChanged', info => {
    for (const key in info) {
        set(key, info[key]);
    }

    for (let listener of listeners) {
        listener(info);
    }
});

eventEmitter.addListener('SHMPreferenceClear', info => {
    if (info != null) {
        //clear key
        const key = info[key];
        if (PREFERENCES[key] !== null) {
            clear(key);
            for (let listener of listeners) {
                listener();
            }
        }
    } else {
        //clear all
        if (Object.keys(PREFERENCES).length !== 0) {
            clear();
            for (let listener of listeners) {
                listener();
            }
        }
    }
});

function addPreferenceChangedListener(listener) {
    listeners.add(listener);
}

function removePreferenceChangedListener(listener) {        
    listeners.remove(listener);
}


let PREFERENCES = {};

try {
    PREFERENCES = JSON.parse(RNPreferenceManager.InitialPreferences);
} catch (err) {
    console.warn(`preference parse exception:${err.message}`);
}

function get(key) {
    if (key != null) {
        return PREFERENCES[key];
    } else {
        return {
            ...PREFERENCES,
        };
    }
}

function set(key, value) {
    if (value === null || typeof value === 'undefined') {
        return clear(key);
    } else {
        try {
            const data = {};
            const safeValue = JSON.parse(JSON.stringify(value));
            PREFERENCES[key] = safeValue;
            data[key] = safeValue;
            return RNPreferenceManager.set(JSON.stringify(data)); 
        } catch (error) {
            return Promise.reject(error);
        }
    }
}

function clear(key) {
    if (value === null || typeof value === 'undefined') {
        PREFERENCES = {};
        return RNPreferenceManager.clear();
    } else {
        delete PREFERENCES[key];
        return RNPreferenceManager.set(JSON.stringify({
            [key]: null
        }));
    }
}

// 设置白名单, (需要接收状态发生改变的keys)
function setWhiteList(list) {
    RNPreferenceManager.setWhiteList(list);
}

export default {
    addPreferenceChangedListener,
    removePreferenceChangedListener,
    setWhiteList,
    get,
    set,
    clear,
};
