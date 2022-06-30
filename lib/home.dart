import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ml/main.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;

  late String output = '';

  late File pickedImage;
  bool isImageLoaded = false;
  late List result;
  late String accuracy = '';
  late String name = '';
  late String numbers = '';

  /*
  getImage() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore!.path);
      isImageLoaded = true;
      applyModel(File(tempStore.path));
    });
  }
  */

  loadModel() async {
    await Tflite.loadModel(
        model: 'lib/assets/model_unquant.tflite',
        labels: 'lib/assets/labels.txt');
  }

  /*
  applyModel(File file) async {
    var res = await Tflite.runModelOnImage(
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      result = res!;
      print('result:' + result.toString());
      String str = result[0]['label'];

      name = str.substring(2);
      accuracy = result != null
          ? (result[0]['confidence'] * 100.0).toString().substring(0, 2) + '%'
          : '';
    });
  }
  */

  loadCamera() async {
    cameraController = CameraController(
      camera![0],
      ResolutionPreset.low,
    );
    cameraController!.initialize().then((value) {
      if (!mounted) {
      } else {
        setState(() {
          cameraController!.startImageStream((imageStream) {
            cameraImage = imageStream;
            runModel();
          });
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      var prediction = await Tflite.runModelOnFrame(
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
      for (var element in prediction!) {
        setState(() {
          result = prediction;
          print('result:' + result.toString());
          String str = result[0]['label'];

          output = str.substring(2);

          accuracy = result != null
              ? (result[0]['confidence'] * 100.0).toString().substring(0, 2) +
                  '%'
              : '';

          //tts.speak(output);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCamera();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController!.dispose();
  }

  TextToSpeech tts = TextToSpeech();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                child: !cameraController!.value.isInitialized
                    ? Container()
                    : AspectRatio(
                        aspectRatio: cameraController!.value.aspectRatio,
                        child: CameraPreview(cameraController!),
                      ),
              ),
            ),
            Text('Result: ' + output),
            Text('Accuracy: ' + accuracy),
            RaisedButton(
              onPressed: () {
                double volume = 1.0;
                tts.setVolume(volume);

                tts.speak(output);
              },
              child: const Text('Press'),
            ),
          ],
        ));
  }
}
