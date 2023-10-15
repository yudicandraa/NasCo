import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watermelon_sound/features/presentation/bloc/prediction_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final recorder = FlutterSoundRecorder();
  bool isRecordReady = false;

  @override
  void initState() {
    super.initState();
    iniRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future iniRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecordReady = true;
    recorder.setSubscriptionDuration(const Duration(microseconds: 500));
  }

  Future record() async {
    if (!isRecordReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecordReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print(audioFile);
  }

  @override
  Widget build(BuildContext context) {
    Container buildIconWidget() => Container(
          height: 200,
          width: 200,
          padding: const EdgeInsets.all(10),
          child: Image.asset('assets/Nenas.png'),
        );

    // Text buildTimerRecorded() => Text(
    //       'Time Recorded: ${const Duration(seconds: 0).toString().split('.').first}',
    //       style: const TextStyle(fontSize: 16, color: Color(0xff679344)),
    //     );
    // StreamBuilder buildTimerRecorded() => ;

    SizedBox buildBtnRecording() => SizedBox(
          width: 250,
          child: ElevatedButton(
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
                // SizedBox(
                //   height: 50,
                //   width: 50,
                //   child: Image(image: AssetImage('assets/mic1.png')),
                // ),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
                ),
                const SizedBox(width: 10),
                const Text('Start Recording', style: TextStyle(fontSize: 14)),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            onPressed: () async {
              if (recorder.isRecording) {
                await stop();
              } else {
                await record();
              }

              setState(() {});
            },
          ),
        );

    Column buildBtnChooseAudioFile() => Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => chooseAudioFile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff679344),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  minimumSize: const Size(double.maxFinite, 50),
                ),
                child: const Text('File'),
              ),
            ),
          ],
        );

    Container buildBtnPickImageByCamera() => Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          height: 50,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff679344),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              minimumSize: const Size(double.maxFinite, 50),
            ),
            child: const Text('Kamera'),
          ),
        );

    BlocBuilder buildResultPrediction() =>
        BlocBuilder<PredictionBloc, PredictionState>(
          builder: (context, state) {
            if (state is PredictionLoading) {
              // ini bisa di sesuaiin lagi kek misalnya mau pakai lottifile
              return const CircularProgressIndicator();
            } else if (state is PredictionLoaded) {
              final label = state.result.label;
              return Text(
                "Hasil Prediksi: $label",
                style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
              );
            } else if (state is PredictionLoadFailue) {}

            return const Text(
              'Hasil Prediksi: ',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
            );
          },
        );

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildIconWidget(),
          const SizedBox(height: 20),
          StreamBuilder<RecordingDisposition>(
            stream: recorder.onProgress,
            builder: (context, snapshot) {
              final duration =
                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;

              print("INI LOG:: ${duration.inMilliseconds}");

              String twoDigits(int n) => n.toString().padLeft(2, "$n");

              final twoDigitMinutes =
                  twoDigits(duration.inMinutes.remainder(60));

              final twoDigitSeconds =
                  twoDigits(duration.inSeconds.remainder(60));

              return Text(
                "Time Recorded: $twoDigitMinutes:$twoDigitSeconds",
                style: const TextStyle(fontSize: 16, color: Color(0xff679344)),
              );
            },
          ),
          const SizedBox(height: 20),
          buildBtnRecording(),
          const SizedBox(height: 10),
          buildBtnChooseAudioFile(),
          const SizedBox(height: 10),
          buildBtnPickImageByCamera(),
          const SizedBox(height: 20),
          buildResultPrediction(),
        ],
      ),
    );
  }
}

Future<void> chooseAudioFile(BuildContext context) async {
  final predictionBloc = context.read<PredictionBloc>();

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.audio,
  );

  if (result != null) {
    final String audioPath = File(result.files.single.path!).path;

    predictionBloc.add(OnCreatePredictAudio(audioPath));
  } else {
    throw Exception('No file selected');
  }
}
