#import "QrImageReader.h"
#import "ZXingObjC.h"

#import <React/RCTConvert.h>

@implementation QrImageReader

RCT_EXPORT_MODULE()

NSString* resultKey = @"result";
NSString* successString = @"success";
NSString* fileDoesNotExist = @"no_file";
NSString* errorCodeKey = @"errorCode";
NSString* errorMessageKey = @"errorMessage";
NSString* noCodes = @"no_codes";
NSString* decodeError = @"decode_error";

RCT_REMAP_METHOD(decode,
                 decodeOptions: (nonnull NSDictionary *)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
  NSMutableDictionary *resultObj = [[NSMutableDictionary alloc]initWithCapacity:3];
  
  CGImageRef imageToDecode = NULL;  // Given a CGImage in which we are looking for barcodes
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSString *imagePath = [RCTConvert NSString: options[@"path"]];
  
  NSURL *url = [NSURL URLWithString: imagePath];
  NSString *path = [url path];
  
  BOOL doesFileExist = [fileManager fileExistsAtPath: path];
  if (doesFileExist) {
    imageToDecode = [[UIImage alloc] initWithContentsOfFile: path].CGImage;
  }
  else {
    // reject
    [resultObj setObject:fileDoesNotExist forKey:errorCodeKey];
    [resultObj setObject:@"File does not exist" forKey:errorMessageKey];
    return;
  }
  
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
  ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
  
  NSError *error = nil;
  
  // There are a number of hints we can give to the reader, including
  // possible formats, allowed lengths, and the string encoding.
  ZXDecodeHints *hints = [ZXDecodeHints hints];
  
  ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
  ZXResult *result = [reader decode:bitmap
                              hints:hints
                              error:&error];
  if (result) {
    // The coded result as a string. The raw data can be accessed with
    // result.rawBytes and result.length.
    NSString *contents = result.text;
    [resultObj setObject: contents forKey:resultKey];
    resolve(resultObj);
    // The barcode format, such as a QR code or UPC-A
    //    ZXBarcodeFormat format = result.barcodeFormat;
  } else {
    // Use error to determine why we didn't get a result, such as a barcode
    // not being found, an invalid checksum, or a format inconsistency.
    
    [resultObj setObject: decodeError forKey:errorCodeKey];
    [resultObj setObject:[error localizedDescription] forKey:errorMessageKey];
    resolve(resultObj);
  }
}

@end
