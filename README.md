# react-native-qr-image-reader

(iOS ONLY FOR NOW)

React Native module to read QR codes and barcodes for iOS ~~& Android~~

iOS uses ZXingify-Objc

## Installation

```sh
yarn install react-native-qr-image-reader
```

## Usage

```js
import QrImageReader from 'react-native-qr-image-reader';

// ...

const { result } = await QrImageReader.decode('file://pathToFile');
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
