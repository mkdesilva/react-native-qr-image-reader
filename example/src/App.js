import React from 'react';
import { launchImageLibrary } from 'react-native-image-picker';
import { StyleSheet, View, Text, Button } from 'react-native';
import QrImageReader from 'react-native-qr-image-reader';
export default function App() {
    const [result, setResult] = React.useState();
    const onChooseImage = () => {
        launchImageLibrary({ mediaType: 'photo' }, async (res) => {
            if (res.uri) {
                console.log(res.uri);
                const { result: decodeResult, errorCode, errorMessage, } = await QrImageReader.decode({ path: res.uri });
                console.log('Error Code: ' + errorCode);
                console.log('Error Message: ' + errorMessage);
                console.log('Result: ' + decodeResult);
                if (decodeResult)
                    setResult(decodeResult);
            }
        });
    };
    return (React.createElement(View, { style: styles.container },
        React.createElement(Button, { title: "Choose Image", onPress: onChooseImage }),
        React.createElement(Text, null,
            "Result: ",
            result)));
}
const styles = StyleSheet.create({
    container: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    box: {
        width: 60,
        height: 60,
        marginVertical: 20,
    },
});
