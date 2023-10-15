import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:watermelon_sound/features/data/datasources/remote_data_source.dart';
import 'package:watermelon_sound/features/data/repositories/predict_repository_impl.dart';
import 'package:watermelon_sound/features/domain/repositories/predict_repository.dart';
import 'package:watermelon_sound/features/domain/usecases/create_audio_predict.dart';
import 'package:watermelon_sound/features/presentation/bloc/prediction_bloc.dart';

final locator = GetIt.instance;

void injectionLocatorSetup() {
  locator.registerFactory(() => PredictionBloc(locator()));

  locator.registerLazySingleton(() => CreatePredictAudioUseCase(
        locator(),
      ));

  locator.registerLazySingleton<PredictRepository>(() => PredictRepositoryImpl(
        locator(),
      ));

  locator.registerLazySingleton<PredictRemoteDataSource>(
    () => PredictRemoteDataSourceImpl(
      client: locator(),
    ),
  );

  locator.registerLazySingleton(() => http.Client());
}
