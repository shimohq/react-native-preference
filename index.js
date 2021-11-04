import {NativeModules, NativeEventEmitter} from 'react-native';

const { RNPreferenceManager } = NativeModules;
const eventEmitter = new NativeEventEmitter(RNPreferenceManager);
const listeners = new Set();

eventEmitter.addListener('SHMPreferenceWhiteListChanged', info => {
    for (const key in info) {
        const value = info[key];
        if (isNil(value)) {
            delete PREFERENCES[key];
        } else {
            try {
                const safeValue = JSON.parse(JSON.stringify(value));
                PREFERENCES[key] = safeValue;
            } catch (error) {
                console.warn('wrong format:', value);
            }
        }
    }

    for (let listener of listeners) {
        listener(info);
    }
});

eventEmitter.addListener('SHMPreferenceClear', info => {
    if (!isNil(info)) {
        //clear key
        const key = info['key'];
        if (!isNil(PREFERENCES[key])) {
            delete PREFERENCES[key];
            for (let listener of listeners) {
                listener({[key]: null});
            }
        }
    } else {
        //clear all
        if (Object.keys(PREFERENCES).length !== 0) {
            PREFERENCES = {};
            for (let listener of listeners) {
                listener({});
            }
        }
    }
});

function addPreferenceChangedListener(listener) {
    listeners.add(listener);
}

function removePreferenceChangedListener(listener) {        
    listeners.delete(listener);
}


let PREFERENCES = {};

try {
    PREFERENCES = JSON.parse(RNPreferenceManager.InitialPreferences);
} catch (err) {
    console.warn(`preference parse exception:${err.message}`);
}

function get(key) {
    return isNil(key) ? PREFERENCES : PREFERENCES[key];
}

function set(key, value) {
    if (isNil(value)) {
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
    if (isNil(key)) {
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

function isNil(value) {
    return value === null || value === undefined
}

export default {
    addPreferenceChangedListener,
    removePreferenceChangedListener,
    setWhiteList,
    get,
    set,
    clear,
};
