import 'package:dartz/dartz.dart';
import 'package:watermelon_sound/core/error/failure.dart';
import 'package:watermelon_sound/features/domain/entities/label.dart';

abstract class PredictRepository {
  Future<Either<Failure, PredictionEntity>> createPrediction(String audioPath);
}
