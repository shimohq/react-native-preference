import React, { Component } from 'react';
import { AppRegistry, StyleSheet, Text, View, TextInput, Button, ScrollView } from 'react-native';

import Preference from 'react-native-preference';

export default class PreferenceExample extends Component {

    constructor(props) {
        super(props);

        this.state = {
          preference: Preference.get()
        };
    }

    _key = null;
    _value = null;

    _clear = () => {
        Preference.clear().then(() => {
            this.setState({
                preference: Preference.get()
            });
        });
    };

    _set = () => {
        if (this._key) {
            Preference.set(this._key, this._value || null).then(() => {
                this.setState({
                    preference: Preference.get()
                });
            });
        }
    };

    _setKey = (key) => {
        this._key = key;
    };

    _setValue = (value) => {
        this._value = value;
    };

    render() {
        return (
            <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
                <Text style={styles.text}>
                    {JSON.stringify(this.state.preference)}
                </Text>

                <Button title="clear" onPress={this._clear} />


                <View>
                    <TextInput style={styles.input} placeholder="key" onChangeText={this._setKey} underlineColorAndroid="transparent" />
                    <TextInput style={styles.input} placeholder="value" onChangeText={this._setValue} underlineColorAndroid="transparent" />
                    <Button title="set" onPress={this._set} />
                </View>
            </ScrollView>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F5FCFF',
    },

    contentContainer: {
        paddingTop: 20,
        alignItems: 'center'
    },

    text: {
        fontSize: 12,
        textAlign: 'center',
        margin: 10,
    },
    input: {
        height: 30,
        width: 240,
        marginBottom: 5,
        paddingHorizontal: 15,
        borderColor: '#ccc',
        borderWidth: StyleSheet.hairlineWidth
    }
});

AppRegistry.registerComponent('Preference', () => PreferenceExample);
