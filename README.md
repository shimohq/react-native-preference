# react-native-preference

Manage react-native app's preference data synchronously

# Installation

```bash
# install library from npm
npm install react-native-preference --save
# link native code
react-native link react-native-preference
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

`Preference.set(key: String|Object, value?: String): Promise`

```

// set one preference
Preference.set('key', 'value');

// set multiple preferences
Preference.set({
    key: 'value',
    foo: 'bar'
});

```

## Clear

`Preference.clear(key?: String): Promise`

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
    Preference.addPrefernceChangedListener(() => {
        this.setState({
            preference: Preference.get(),
        });
    });
```
