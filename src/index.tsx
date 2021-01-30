import { NativeModules } from 'react-native';

type ErrorCode = 'no_file' | 'decode_error' | 'other';

type DecodeResult = {
  errorCode?: ErrorCode;
  errorMessage?: string;
  result?: string;
};

type QrImageReaderType = {
  decode(imagePath: string): Promise<DecodeResult>;
};

const { QrImageReader } = NativeModules;

export default QrImageReader as QrImageReaderType;
