package com.example.one_famory

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val galleryChannel = "one_famory/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, galleryChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "savePngToGallery" -> {
                    val fileName = call.argument<String>("fileName") ?: "famory_invite.png"
                    val bytes = call.argument<ByteArray>("bytes")

                    if (bytes == null) {
                        result.error("missing_bytes", "No image bytes were provided.", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedPath = savePngToGallery(fileName, bytes)
                        result.success(savedPath)
                    } catch (error: Exception) {
                        result.error("save_failed", error.message ?: "Could not save image.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun savePngToGallery(fileName: String, bytes: ByteArray): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/Famory")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: throw IllegalStateException("Could not create gallery image.")

        resolver.openOutputStream(uri)?.use { stream ->
            stream.write(bytes)
        } ?: throw IllegalStateException("Could not open gallery image.")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        return uri.toString()
    }
}
