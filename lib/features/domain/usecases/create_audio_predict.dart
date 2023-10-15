import 'package:dartz/dartz.dart';
import 'package:watermelon_sound/core/error/failure.dart';
import 'package:watermelon_sound/features/domain/entities/label.dart';
import 'package:watermelon_sound/features/domain/repositories/predict_repository.dart';

class CreatePredictAudioUseCase {
  final PredictRepository repository;

  CreatePredictAudioUseCase(this.repository);

  Future<Either<Failure, PredictionEntity>> call(String audioPath) =>
      repository.createPrediction(audioPath);
}
