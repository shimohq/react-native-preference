import { NativeModules, NativeEventEmitter } from 'react-native';

const { RNPreferenceManager } = NativeModules;

let PREFERENCES = {};

try {
    PREFERENCES = JSON.parse(RNPreferenceManager.InitialPreferences);
} catch (err) {
    console.warn(`preference parse exception:${err.message}`);
}

function get(key?: String) {
    if (key != null) {
        return PREFERENCES[key];
    } else {
        return {
            ...PREFERENCES
        };
    }
}

function set(key: String|Object, value?: String) {
    let data = {};

    if (typeof key === 'object') {
        data = {
            ...key
        };
    } else {
        data[key] = value;
    }

    Object.keys(data).forEach((name) => {
        const stringfied = JSON.stringify(data[name]);
        if (stringfied) {
            PREFERENCES[name] = JSON.parse(stringfied);
        } else {
            delete PREFERENCES[name];
        }
    });

    return RNPreferenceManager.set(JSON.stringify(PREFERENCES));
}

function clear(key?: String|Array) {
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

export default {
    get,
    set,
    clear
}
