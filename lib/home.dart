import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";
  dynamic currentObject = null;

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res;
    switch (_model) {
      // case yolo:
      //   res = await Tflite.loadModel(
      //     model: "assets/yolov2_tiny.tflite",
      //     labels: "assets/yolov2_tiny.txt",
      //   );
      //   break;

      case mobilenet:
        res = await Tflite.loadModel(
           model: "assets/ssd_mobilenet.tflite",
           labels: "assets/ssd_mobilenet.txt");
        break;
      //
      // case posenet:
      //   res = await Tflite.loadModel(
      //       model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
      //   break;

      default:
        res = await Tflite.loadModel(
            // model: "assets/model_unquant.tflite",
            // labels: "assets/labels.txt");
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) async{
    print("img height is $imageHeight");
    print("img width is $imageWidth");
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
   // checkRecognitions(_recognitions);
  }

  dynamic checkRecognitions(List<dynamic> results) async{
    results.map((re) {
      print("current object is ${re["detectedClass"]}");
      if(re["detectedClass"] == "book"){ // book //
        currentObject = re;
        return currentObject;
      }
    });
    return currentObject;
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: const Text(ssd),
                    onPressed: () => onSelect(ssd),
                  ),
                  // RaisedButton(
                  //   child: const Text(yolo),
                  //   onPressed: () => onSelect(yolo),
                  // ),
                  // RaisedButton(
                  //   child: const Text(mobilenet),
                  //   onPressed: () => onSelect(mobilenet),
                  // ),
                  // RaisedButton(
                  //   child: const Text(posenet),
                  //   onPressed: () => onSelect(posenet),
                  // ),
                ],
              ),
            )
          : Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                // we need to check if detection label is a car here
                _recognitions == null || _recognitions == []
                    ? Container()
                    : BndBox(
                       // _recognitions == null ? [] : _recognitions,
                       _recognitions,
                      // _recognitions[0],
                        math.max(_imageHeight, _imageWidth),
                        math.min(_imageHeight, _imageWidth),
                        screen.height,
                        screen.width,
                        _model),
              ],
            ),
    );
  }
}
