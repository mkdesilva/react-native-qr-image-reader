import { NativeModules } from 'react-native';

type QrImageReaderType = {
  multiply(a: number, b: number): Promise<number>;
};

const { QrImageReader } = NativeModules;

export default QrImageReader as QrImageReaderType;
