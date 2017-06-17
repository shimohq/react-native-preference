import { NativeModules } from 'react-native';

const { RNPreferenceManager } = NativeModules;

let PREFERENCES = {};

const PREFERENCE_PREFIX_REG = /^RNPreference:/;

function processPreferences(preferences:Object) {
    PREFERENCES = Object.keys(preferences).reduce(function(prev, key) {
        const value = preferences[key];
        if (PREFERENCE_PREFIX_REG.test(key)) {
            try {
                prev[key.replace(PREFERENCE_PREFIX_REG, '')] = JSON.parse(value);
            } catch (err) {
                prev[key] = null;
            }
        } else {
            prev[key] = value;
        }
        return prev;
    }, {});


    return PREFERENCES;
}

processPreferences(RNPreferenceManager.InitialPreferences);

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


    data = Object.keys(data).reduce((prev, name) => {
        const stringified = JSON.stringify(data[name]);
        prev['RNPreference:' + name] = stringified;
        // Keep same data in the native side and js side
        PREFERENCES[name] = JSON.parse(stringified);
        return prev;
    }, {});

    return RNPreferenceManager.set(data).then(processPreferences);
}

function clear(key?: String|Array) {
    let result;
    if (key == null) {
        PREFERENCES = {};
        result = RNPreferenceManager.clearAll();
    } else {
        let keys;
        if (!Array.isArray(key)) {
            keys = [key];
        }

        keys = keys.map((name) => {
            return name.toString();
        });

        result = RNPreferenceManager.clear(keys);
    }

    return result.then(processPreferences);
}

function sync() {
    return RNPreferenceManager.sync().then(processPreferences);
}

export default {
    get,
    set,
    clear,
    sync
}
