import { NativeModules } from 'react-native';

export type ErrorCode = 'no_file' | 'decode_error' | 'other';

export type DecodeResult = {
  errorCode?: ErrorCode;
  errorMessage?: string;
  result?: string;
};

export type DecodeOptions = {
  path?: string;
};

type QrImageReaderType = {
  decode(options: DecodeOptions): Promise<DecodeResult>;
};

const { QrImageReader } = NativeModules;

export default QrImageReader as QrImageReaderType;
