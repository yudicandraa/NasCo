// import 'dart:io';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_audio/tflite_audio.dart';
// import 'package:watermelon_sound/record.dart';

// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   bool loading = true;
//   late File _image;
//   late List _output;
//   final imagepicker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     loadmodel().then((value) {
//       setState(() {});
//     });
//   }

//   detectimage(File image) async {
//     var prediction = await Tflite.runModelOnImage(
//         path: image.path,
//         numResults: 2,
//         threshold: 0.6,
//         imageMean: 127.5,
//         imageStd: 127.5);

//     setState(() {
//       _output = prediction!;
//       loading = false;
//     });
//   }

//   detectaudio(File audio) async {}

//   loadmodel() async {
//     try {
//       await TfliteAudio.loadModel(
//           model: 'assets/audio.tflite',
//           label: 'assets/labels.txt',
//           inputType: 'rawAudio');
//     } catch (e) {
//       print("Error loading TensorFlow Lite model: $e");
//     }
//     TfliteAudio.setSpectrogramParameters(nMFCC: 13, hopLength: 512);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   pickimage_camera() async {
//     var image = await imagepicker.pickImage(source: ImageSource.camera);
//     if (image == null) {
//       return null;
//     } else {
//       _image = File(image.path);
//     }
//     detectimage(_image);
//   }

//   // pickimage_gallery() async {
//   //   var image = await imagepicker.pickImage(source: ImageSource.gallery);
//   //   if (image == null) {
//   //     return null;
//   //   } else {
//   //     _image = File(image.path);
//   //   }
//   //   detectimage(_image);
//   // }

//   pickfile_audio() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles();

//       if (result != null && result.files.isNotEmpty) {
//         File file = File(result.files.single.path!);
//         print(file); // Use the null-aware operator here
//         detectaudio(file);
//         // Now you can use 'file' to work with the selected file.
//       } else {
//         // User canceled the picker or no files were selected.
//       }
//     } catch (e) {
//       // Handle any potential errors that may occur during file picking.
//       print("Error picking file: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var h = MediaQuery.of(context).size.height;
//     var w = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: Container(
//         height: h,
//         width: w,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 200,
//               width: 200,
//               padding: EdgeInsets.all(10),
//               child: Image.asset('assets/logo.png'),
//             ),
//             // Container(
//             //     child: Text(
//             //   'Kubus Suara',
//             // )),
//             SizedBox(height: 20),
//             Container(
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.only(left: 10, right: 10),
//                     height: 50,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Navigate to the next page
//                         pickimage_camera();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         primary: Color(0xff679344),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                         minimumSize: Size(180, 50),
//                       ),
//                       child: Text('Kamera'),
//                     ),
//                   ),
//                   // SizedBox(height: 10),
//                   // Container(
//                   //   padding: EdgeInsets.only(left: 10, right: 10),
//                   //   height: 50,
//                   //   width: double.infinity,
//                   //   child: ElevatedButton(
//                   //     onPressed: () {
//                   //       // Navigate to the next page
//                   //       pickimage_gallery();
//                   //     },
//                   //     style: ElevatedButton.styleFrom(
//                   //       primary: Color(0xff679344),
//                   //       shape: RoundedRectangleBorder(
//                   //         borderRadius: BorderRadius.circular(25.0),
//                   //       ),
//                   //       minimumSize: Size(180, 50),
//                   //     ),
//                   //     child: Text('Galeri'),
//                   //   ),
//                   // ),
//                   // SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.only(left: 10, right: 10),
//                     height: 50,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // Navigate to the next page
//                         pickfile_audio();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         primary: Color(0xff679344),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(25.0),
//                         ),
//                         minimumSize: Size(180, 50),
//                       ),
//                       child: Text('File'),
//                     ),
//                   ),
//                   // Container(
//                   //   padding: EdgeInsets.only(left: 10, right: 10),
//                   //   height: 50,
//                   //   width: double.infinity,
//                   //   child: ElevatedButton(
//                   //     onPressed: () {
//                   //       Navigator.push(
//                   //         context,
//                   //         MaterialPageRoute(builder: (context) => RecordPage()),
//                   //       );
//                   //     },
//                   //     style: ElevatedButton.styleFrom(
//                   //       primary: Color(0xff679344),
//                   //       shape: RoundedRectangleBorder(
//                   //         borderRadius: BorderRadius.circular(25.0),
//                   //       ),
//                   //       minimumSize: Size(180, 50),
//                   //     ),
//                   //     child: Text('Record'),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),

//             loading != true
//                 ? Container(
//                     child: Column(
//                       children: [
//                         Container(
//                           height: 220,
//                           // width: double.infinity,
//                           padding: EdgeInsets.all(15),
//                           child: Image.file(_image),
//                         ),
//                         _output != null
//                             ? Text(
//                                 (_output[0]['label']).toString().substring(2),
//                               )
//                             : Text(''),
//                         _output != null
//                             ? Text(
//                                 'Confidence: ' +
//                                     (_output[0]['confidence']).toString(),
//                                 style: TextStyle(fontSize: 18))
//                             : Text('')
//                       ],
//                     ),
//                   )
//                 : Container()
//           ],
//         ),
//       ),
//     );
//   }
// }
