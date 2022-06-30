import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late File pickedImage;
  bool isImageLoaded = false;
  late List result;
  late String accuracy = '';
  late String name = '';
  late String numbers = '';
  getImage() async {
    var tempStore = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      pickedImage = File(tempStore!.path);
      isImageLoaded = true;
      applyModel(File(tempStore.path));
    });
  }

  loadModel() async {
    var result = await Tflite.loadModel(
        model: 'lib/assets/model_unquant.tflite',
        labels: 'lib/assets/labels.txt');
    print("Result" + result!);
  }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isImageLoaded
              ? Center(
                  child: Container(
                    width: 350.0,
                    height: 350.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(pickedImage.path)),
                            fit: BoxFit.cover)),
                  ),
                )
              : Container(),
          Text('Name:' + name),
          Text('Accuracy:' + accuracy)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
      ),
    );
  }
}
