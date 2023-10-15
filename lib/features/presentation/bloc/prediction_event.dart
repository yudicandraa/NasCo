part of 'prediction_bloc.dart';

sealed class PredictionEvent extends Equatable {
  const PredictionEvent();

  @override
  List<Object> get props => [];
}

class OnCreatePredictAudio extends PredictionEvent {
  final String audioPath;

  const OnCreatePredictAudio(this.audioPath);

  @override
  List<Object> get props => [audioPath];
}
