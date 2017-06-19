import { NativeModules } from 'react-native';

const { RNPreferenceManager } = NativeModules;

let PREFERENCES = RNPreferenceManager.InitialPreferences;

function get(key?: String) {
  if (key != null) {
    return PREFERENCES[key];
  } else {
    return {
      ...PREFERENCES
    };
  }
}

setTimeout(() => {
    console.log(2222, RNPreferenceManager.InitialPreferences);
}, 200);

function set(key: String|Object, value?: String) {
    let sets = {};

    if (typeof key === 'object') {
        sets = {
            ...key
        };
    } else {
        sets[key] = value;
    }

    Object.keys(sets).forEach((name) => {
        sets[name] = sets[name] || null;
    });

    Object.assign(PREFERENCES, sets);

    return RNPreferenceManager.set(sets);
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

    return result.then(() => RNPreferenceManager.sync());
}

function sync() {
    return RNPreferenceManager.sync().then((preferences) => {
        PREFERENCES = preferences;
    });
}

export default {
    get,
    set,
    clear,
    sync
}
