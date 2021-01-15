import {NativeModules, NativeEventEmitter} from 'react-native';

const {RNPreferenceManager} = NativeModules;
const eventEmitter = new NativeEventEmitter(RNPreferenceManager);
const listeners = new Set();

eventEmitter.addListener('SHMPreferenceWhiteListChanged', (info) => {
    for (const key in info) {
        set(key, info[key]);
    }

    for (let listener of listeners) {
        listener();
    }
});

eventEmitter.addListener('SHMPreferenceClear', () => {
    if (Object.keys(PREFERENCES).length !== 0) {
        clear();
        for (let listener of listeners) {
            listener();
        }
    }
});

function addPrefernceChangedListener(callback) {
    const listener = () => {
        callback();
    };
    listeners.add(listener);
    return () => {
        listeners.delete(listener);
    };
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
    let data = {};
    let keyStr;

    if (typeof key === 'object') {
        data = {
            ...key,
        };
        keyStr = JSON.stringify(key);
    } else {
        data[key] = value;
        keyStr = key;
    }

    Object.keys(data).forEach((name) => {
        const stringfied = JSON.stringify(data[name]);
        if (stringfied) {
            PREFERENCES[name] = JSON.parse(stringfied);
        } else {
            delete PREFERENCES[name];
        }
    });

    return RNPreferenceManager.set(keyStr, value);
}

function clear(key) {
    if (key == null) {
        PREFERENCES = {};
        return RNPreferenceManager.clear();
    } else {
        let keys;
        if (!Array.isArray(key)) {
            keys = [key];
        }

        keys.map((name) => {
            delete PREFERENCES[name];
        });

        return RNPreferenceManager.set(JSON.stringify(PREFERENCES));
    }
}

// 设置白名单, (需要接收状态发生改变的keys)
function setWhiteList(list) {
    RNPreferenceManager.setWhiteList(list);
}

export default {
    addPrefernceChangedListener,
    setWhiteList,
    get,
    set,
    clear,
};
