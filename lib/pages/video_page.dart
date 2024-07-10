import 'package:camera/camera.dart';
import 'package:chatacter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  int cameraNumber = 1;
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';
  bool isModelRunning = false; // Flag to track if model is running

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadModel();
  }

  loadCamera() async {
    if (cameras == null || cameras!.isEmpty) {
      print('No cameras found');
      return;
    }
    if (cameraNumber >= cameras!.length) {
      print('Invalid camera number');
      return;
    }
    try {
      cameraController =
          CameraController(cameras![cameraNumber], ResolutionPreset.high);
      await cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
          if (!isModelRunning) {
            runModel();
          }
        });
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  runModel() async {
    // Check if cameraImage is not null, the model is not already running, and the camera is actively streaming images
    if (cameraImage != null && !isModelRunning) {
      isModelRunning = true; // Set flag to true before running model
      try {
        var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true,
        );
        print('Output Here!!!!!!!!!!!! ... $predictions');
        if (predictions != null) {
          predictions.forEach((element) {
            setState(() {
              output = element['label'];
            });
          });
        }
      } catch (e) {
        print("Error running model: $e");
      } finally {
        isModelRunning = false; // Reset flag after running model
      }
    }
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/models/model.tflite",
          labels: "assets/models/labels.txt");
      print("Model loaded successfully.");
    } catch (e) {
      print("Failed to load the model: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    // Tflite.close();
    super.dispose();
  }

  switchCamera() {
    setState(() {
      cameraNumber = (cameraNumber + 1) % cameras!.length;
      if (cameraController != null) {
        cameraController!.dispose();
      }
      loadCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Emotion Detection App')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: !cameraController!.value.isInitialized
                  ? Container()
                  : AspectRatio(
                      aspectRatio: cameraController!.value.aspectRatio,
                      child: CameraPreview(cameraController!),
                    ),
            ),
          ),
          Text(
            output,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          ElevatedButton(
            onPressed: switchCamera,
            child: Text('Switch Camera'),
          ),
        ],
      ),
    );
  }
}
