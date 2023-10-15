import 'dart:convert';

import 'package:watermelon_sound/core/constants/constants.dart';
import 'package:watermelon_sound/features/data/models/label_model.dart';
import 'package:http/http.dart' as http;

abstract class PredictRemoteDataSource {
  Future<PredictionModel> createPrediction(String audioPath);
}

class PredictRemoteDataSourceImpl extends PredictRemoteDataSource {
  final http.Client client;

  PredictRemoteDataSourceImpl({required this.client});

  @override
  Future<PredictionModel> createPrediction(String audioPath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.createPredictAudio()),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        audioPath,
      ),
    );
    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return PredictionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prediction');
    }
  }
}
