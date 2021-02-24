# react-native-preference

Manage react-native app's preference data synchronously

# Installation

```bash
# install library from npm
npm install react-native-preference --save
```

# Usage

## Import

```javascript
import Preference from 'react-native-preference';
```

## Get

`Preference.get(key?: String)`

```javascript

// get all preferences
const preferences = Preference.get();

// get preference named `some-preference` 
const preference = Preference.get('some-preference');

```

## Set

`Preference.set(key: string, value?: string): Promise<void>`

```

// set preference
Preference.set('key', 'value');

```

## Clear

`Preference.clear(key?: string): Promise<void>`

```
// clear all preference data
Preference.clear();

// clear preference for key 'foo'
Preference.clear('foo');
```


## White List 
```
// set keys to white list, when preference value changed in white list changed, listener calls back.
    Preference.setWhiteList(['a', 'b', 'c']);
    Preference.addPreferenceChangedListener((changed) => {
        console.log('preference has changed: changed');
    });
```
