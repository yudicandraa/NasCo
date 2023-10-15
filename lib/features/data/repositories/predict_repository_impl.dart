import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:watermelon_sound/core/error/failure.dart';

import 'package:watermelon_sound/features/domain/entities/label.dart';

import '../../../core/error/exception.dart';
import '../../domain/repositories/predict_repository.dart';
import '../datasources/remote_data_source.dart';

class PredictRepositoryImpl implements PredictRepository {
  final PredictRemoteDataSource remoteDataSource;

  PredictRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PredictionEntity>> createPrediction(
    String audioPath,
  ) async {
    try {
      final result = await remoteDataSource.createPrediction(audioPath);
      return Right(result.toEntity());
    } on ServerException {
      return const Left(ServerFailure('An error has occurred'));
    } on SocketException {
      return const Left(ConnectionFailure('Failed to connect to the network'));
    }
  }
}
