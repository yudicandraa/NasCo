import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:watermelon_sound/features/domain/entities/label.dart';
import 'package:watermelon_sound/features/domain/usecases/create_audio_predict.dart';

part 'prediction_event.dart';
part 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final CreatePredictAudioUseCase createPredictAudio;

  PredictionBloc(this.createPredictAudio) : super(PredictionEmpty()) {
    on<OnCreatePredictAudio>((event, emit) async {
      emit(PredictionLoading());

      final result = await createPredictAudio(event.audioPath);

      result.fold(
        (failure) => emit(PredictionLoadFailue(failure.message)),
        (data) => emit(PredictionLoaded(data)),
      );
    });
  }
}
