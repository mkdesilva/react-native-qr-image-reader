import React from 'react';
import { launchImageLibrary } from 'react-native-image-picker';
import { StyleSheet, View, Text, Button } from 'react-native';
import QrImageReader, { DecodeOptions } from 'react-native-qr-image-reader';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  const decode = async (options: DecodeOptions) => {
    const {
      result: decodeResult,
      errorCode,
      errorMessage,
    } = await QrImageReader.decode(options);

    console.log('Error Code: ' + errorCode);
    console.log('Error Message: ' + errorMessage);
    console.log('Result: ' + decodeResult);

    if (decodeResult) setResult(decodeResult);
  };

  const onChooseImage = () => {
    launchImageLibrary({ mediaType: 'photo' }, async (res) => {
      decode({
        path: res.uri,
      });
    });
  };

  return (
    <View style={styles.container}>
      <Button title="Choose Image" onPress={onChooseImage} />
      <Text>Result: {result}</Text>
    </View>
  );
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
