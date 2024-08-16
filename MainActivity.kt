package com.example.yourapp

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.core.*
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example/height"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "processImage") {
                val imagePath = call.argument<String>("imagePath")
                val referenceHeight = call.argument<Double>("referenceHeight")
                if (imagePath != null && referenceHeight != null) {
                    val height = measureTreeHeight(imagePath, referenceHeight)
                    result.success(height)
                } else {
                    result.error("INVALID_ARGUMENT", "Arguments are null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun measureTreeHeight(imagePath: String, referenceHeight: Double): Double {
        // Initialize OpenCV
        if (!OpenCVLoader.initDebug()) {
            println("OpenCV initialization failed.")
            return 0.0
        }

        // Load the image
        val img = Imgcodecs.imread(imagePath)
        if (img.empty()) {
            println("Could not load image.")
            return 0.0
        }

        // Convert the image to grayscale
        val gray = Mat()
        Imgproc.cvtColor(img, gray, Imgproc.COLOR_BGR2GRAY)

        // Apply Gaussian blur to the grayscale image
        Imgproc.GaussianBlur(gray, gray, Size(5.0, 5.0), 0.0)

        // Perform Canny edge detection
        val edges = Mat()
        Imgproc.Canny(gray, edges, 50.0, 150.0)

        // Find contours in the image
        val contours = ArrayList<MatOfPoint>()
        val hierarchy = Mat()
        Imgproc.findContours(edges, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE)

        if (contours.isEmpty()) {
            println("No contours found.")
            return 0.0
        }

        // Find the largest contour, which we assume is the tree
        var maxArea = 0.0
        var largestContour: MatOfPoint? = null
        for (contour in contours) {
            val area = Imgproc.contourArea(contour)
            if (area > maxArea) {
                maxArea = area
                largestContour = contour
            }
        }

        if (largestContour == null) {
            println("No valid contour found.")
            return 0.0
        }

        // Get the bounding rectangle around the largest contour (tree)
        val boundingRect = Imgproc.boundingRect(largestContour)

        // Draw the bounding rectangle on the original image for visualization (optional)
        Imgproc.rectangle(img, boundingRect.tl(), boundingRect.br(), Scalar(0.0, 255.0, 0.0), 2)

        // Calculate the height of the tree in pixels
        val treePixelHeight = boundingRect.height.toDouble()

        // Assuming we have a reference object with known height in the image
        // The reference height in pixels should be determined similarly
        // Here, for demonstration purposes, we are directly using the bounding rectangle height
        val referencePixelHeight = treePixelHeight // Replace this with the actual reference height in pixels

        // Calculate the real-world height of the tree
        return (treePixelHeight / referencePixelHeight) * referenceHeight
    }
}
