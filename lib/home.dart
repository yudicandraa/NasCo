// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
// import 'dart:convert';

import 'dart:io';
// import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:path/path.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_audio/tflite_audio.dart';
// import 'package:watermelon_sound/record.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();
  bool isRecording = false;
  String? audioFilePath; // Store the path of the recorded audio
  Timer? timer;
  int elapsedTimeInSeconds = 0;
  bool loading = true;
  late File _image;
  // late List _output;
  final imagepicker = ImagePicker();
  String predictedLabel = '';

  @override
  void initState() {
    super.initState();
    initRecorder();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      // _output = prediction!;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.closePlayer(); // Close the player when disposing
    timer?.cancel();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Microphone permission denied";
    }
    await recorder.openRecorder(); // Open audio session for recording
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  pickimageCamera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimageGallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  Future<void> pickFileAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final audioFile = File(result.files.single.path!);

      var url =
          Uri.parse('https://235c-36-85-110-108.ngrok-free.app/upload_audio/');

      var request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      try {
        var streamedResponse = await request.send();

        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          print('Audio file uploaded successfully');

          var data = jsonDecode(response.body);
          print("Decoded response body: ${data['predicted_label']}");

          setState(() {
            predictedLabel = data['predicted_label'].toString();
          });
        } else {
          print(
              'Failed to upload audio file. Status code: ${response.statusCode}');
          throw Exception('Failed to upload audio file');
        }
      } catch (e) {
        print('Error uploading audio file: $e');
        rethrow;
      }
    } else {
      throw Exception('No file selected');
    }
  }

  Future startRecord() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final audioDirectory = Directory('${appDirectory.path}/audio');

    if (!audioDirectory.existsSync()) {
      audioDirectory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final audioFileName =
        'audio_$timestamp.wav'; // Change the desired audio format here

    final filePath = '${audioDirectory.path}/$audioFileName';

    try {
      await recorder.startRecorder(
        toFile: filePath,
        // Set a valid codec, e.g., Codec.pcm16WAV or Codec.aac
      );
      setState(() {
        isRecording = true;
        audioFilePath = filePath;
      });
      print('Recording started: $audioFilePath');
    } catch (e) {
      print('Error starting recording: $e');
    }

    startTimer();
    if (audioFilePath != null) {
      final audioFile = File(audioFilePath!);
      if (audioFile.existsSync()) {
      } else {
        print('Audio file does not exist at path: $audioFilePath');
      }
    }
    // Load and predict audio data
    if (audioFilePath != null) {
      final audioFile = File(audioFilePath!);
      if (audioFile.existsSync()) {
        // Preprocess the audio data and make predictions
      } else {
        print('Audio file does not exist at path: $audioFilePath');
      }
    }
  }

  Future stopRecord() async {
    if (isRecording) {
      try {
        final filePath = await recorder.stopRecorder();
        setState(() {
          isRecording = false;
          audioFilePath = filePath; // Update the audio file path
          elapsedTimeInSeconds = 0;
        });
        stopTimer();
        if (audioFilePath != null) {
          print('Recording stopped successfully: $audioFilePath');
          final audioFile = File(audioFilePath!);
          if (audioFile.existsSync()) {
            // Proceed with uploading the audio file to Firebase Storage
            // ...
          } else {
            print('Audio file does not exist at path: $audioFilePath');
          }
        } else {
          print('No recorded audio file available.');
        }
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedTimeInSeconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print(predictedLabel);
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SizedBox(
        height: h,
        width: w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/Nenas.png'),
            ),
            const SizedBox(height: 20),
            Text(
              'Time Recorded: ${Duration(seconds: elapsedTimeInSeconds).toString().split('.').first}',
              style: const TextStyle(fontSize: 16, color: Color(0xff679344)),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to the next page
                  if (recorder.isRecording) {
                    await stopRecord();
                  } else {
                    await startRecord();
                  }
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff679344),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  minimumSize: const Size(60, 60),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      height: 50,
                      width: 50,
                      child: Image(image: AssetImage('assets/mic1.png')),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                        recorder.isRecording
                            ? 'Stop Recording'
                            : 'Start Recording',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page
                      pickFileAudio();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff679344),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      minimumSize: const Size(180, 50),
                    ),
                    child: const Text('File'),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page
                      pickimageCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff679344),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      minimumSize: const Size(180, 50),
                    ),
                    child: const Text('Kamera'),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Hasil Prediksi: ${predictedLabel ?? ""}',
              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
