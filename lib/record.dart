import 'package:flutter/material.dart';
import 'package:tflite_audio/tflite_audio.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  String _sound = "Press the button to start";
  bool _recording = false;
  late Stream<Map<dynamic, dynamic>> result;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
        model: 'assets/soundclassifier.tflite',
        label: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        inputType: 'rawAudio');
  }

  void _recorder() {
    String recognition = "";
    if (!_recording) {
      setState(() => _recording = true);
      result = TfliteAudio.startAudioRecognition(
        numOfInferences: 1,
        sampleRate: 44100,
        bufferSize: 22016,
      );
      result.listen((event) {
        recognition = event["recognitionResult"];
      }).onDone(() {
        setState(() {
          _recording = false;
          _sound = recognition.split(" ")[1];
        });
      });
    }
  }

  void _stop() {
    TfliteAudio.stopAudioRecognition();
    setState(() => _recording = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "What's this sound?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            MaterialButton(
              onPressed: _recorder,
              color: _recording ? Colors.grey : Colors.pink,
              textColor: Colors.white,
              child: Icon(Icons.mic, size: 60),
              shape: CircleBorder(),
              padding: EdgeInsets.all(25),
            ),
            Text(
              '$_sound',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
    );
  }
}
