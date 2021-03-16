package com.reactnativeqrimagereader

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import com.facebook.react.bridge.*
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import java.io.InputStream
import javax.annotation.Nullable
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt


class QrImageReaderModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "QrImageReader"
  }

  @Nullable
  @Throws(Exception::class)
  private fun getBitmapFromFileString(path: String): Bitmap? {
    val uri = Uri.parse(path)

    var iStream: InputStream? = null
    var image: Bitmap?

    try {
      iStream = reactApplicationContext.contentResolver.openInputStream(uri)
      image = BitmapFactory.decodeStream(iStream)
    } finally {
      iStream?.close()
    }

    return image
  }

  @ReactMethod
  fun decode(options: ReadableMap, promise: Promise) {
    var imagePath = options.getString("path")
    print(imagePath)

    val map = Arguments.createMap()
    if (imagePath == null) {
      map.putString("errorCode", "no_file")
      promise.resolve(map)
      return
    }

    var bitmap = getBitmapFromFileString(imagePath)

    if (bitmap == null) {
      decodeError(map, promise)
      return
    }

    var codeString = readCodeFromBitmap(bitmap)

    if (codeString == null) {
      // If no code was found, try to scale down the image and read the code again
      bitmap = scaleDown(bitmap, 400f)
      codeString = readCodeFromBitmap(bitmap)
    }

    if (codeString == null) {
      decodeError(map, promise)
      return
    }

    map.putString("result", codeString)
    promise.resolve(map)
  }

  private fun decodeError(map: WritableMap, promise: Promise) {
    map.putString("errorCode", "decode_error")
    promise.resolve(map)
  }

  private fun readCodeFromBitmap(bMap: Bitmap): String? {
    var contents: String? = null
    val intArray = IntArray(bMap.width * bMap.height)
    //copy pixel data from the Bitmap into the 'intArray' array
    bMap.getPixels(intArray, 0, bMap.width, 0, 0, bMap.width, bMap.height)
    val source: LuminanceSource = RGBLuminanceSource(bMap.width, bMap.height, intArray)
    val bitmap = BinaryBitmap(HybridBinarizer(source))
    val reader: Reader = MultiFormatReader()
    try {
      val result: Result = reader.decode(bitmap)
      contents = result.text
    } catch (e: NotFoundException) {
      e.printStackTrace()
    } catch (e: ChecksumException) {
      e.printStackTrace()
    } catch (e: FormatException) {
      e.printStackTrace()
    }
    return contents
  }

  private fun scaleDown(realImage: Bitmap, maxImageSize: Float,
                        filter: Boolean = true): Bitmap {
    val minDimension = min(realImage.width, realImage.height);
    val maxDimension = max(realImage.width, realImage.height);

    val aspectRatio = minDimension.toFloat() / maxDimension;
    if (aspectRatio <= 0.2) { // Don't resize images that are very skinny
      return realImage;
    }

    val scaleRatio = min(
      maxImageSize / realImage.width,
      maxImageSize / realImage.height)
    if (scaleRatio >= 1) return realImage; // Only rescale if the image will be scaled down
    val width = (scaleRatio * realImage.width).roundToInt();
    val height = (scaleRatio * realImage.height).roundToInt();
    return Bitmap.createScaledBitmap(realImage, width,
      height, filter)
  }
}
