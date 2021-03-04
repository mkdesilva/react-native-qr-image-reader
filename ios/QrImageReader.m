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

- (UIImage *)compressImage:(UIImage *)originalImage {
  NSData* data = UIImageJPEGRepresentation(originalImage, 0.8);
  UIImage *image = [UIImage imageWithData:data];
  CGFloat minDimension = MIN(image.size.width, image.size.height);
  CGFloat maxDimension = MAX(image.size.width, image.size.height);
  CGFloat aspectRatio = minDimension / maxDimension;
  
  if (aspectRatio <= 0.2) { // Don't resize images if they are skinny
    return image;
  }
  
  float width = 400;
  float height = 400;
  
  if (image.size.width <= width && image.size.height <= height) {
    return image;
  }

  CGFloat oldWidth = image.size.width;
  CGFloat oldHeight = image.size.height;
  
  CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
  
  CGFloat newHeight = oldHeight * scaleFactor;
  CGFloat newWidth = oldWidth * scaleFactor;
  
  UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
  [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (NSString *) readCodeFromImage:(CGImageRef) imageToDecode error: (NSError **) error {
  
  ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
  ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
  ZXDecodeHints *hints = [ZXDecodeHints hints];
  
  ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
  ZXResult *result = [reader decode:bitmap
                              hints:hints
                              error:error];
  if (result) {
    return result.text;
  }
  return nil;
}

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
    UIImage* uiImage = [[UIImage alloc] initWithContentsOfFile: path];
    imageToDecode = [self compressImage: uiImage].CGImage;
  }
  else {
    // reject
    [resultObj setObject:fileDoesNotExist forKey:errorCodeKey];
    [resultObj setObject:@"File does not exist" forKey:errorMessageKey];
    return;
  }
  
  NSError *error = nil;
  
  NSString* result = [self readCodeFromImage:imageToDecode error:&error];
  
  if (result) {
    [resultObj setObject: result forKey:resultKey];
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
