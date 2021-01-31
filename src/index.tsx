import { NativeModules } from 'react-native';

type ErrorCode = 'no_file' | 'decode_error' | 'other';

type DecodeResult = {
  errorCode?: ErrorCode;
  errorMessage?: string;
  result?: string;
};

type DecodeOptions = {
  path: string;
};

type QrImageReaderType = {
  decode(options: DecodeOptions): Promise<DecodeResult>;
};

const { QrImageReader } = NativeModules;

export default QrImageReader as QrImageReaderType;
