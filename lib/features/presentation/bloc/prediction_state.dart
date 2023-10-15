part of 'prediction_bloc.dart';

sealed class PredictionState extends Equatable {
  const PredictionState();

  @override
  List<Object> get props => [];
}

class PredictionEmpty extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionLoaded extends PredictionState {
  final PredictionEntity result;

  const PredictionLoaded(this.result);

  @override
  List<Object> get props => [result];
}

class PredictionLoadFailue extends PredictionState {
  final String message;

  const PredictionLoadFailue(this.message);

  @override
  List<Object> get props => [message];
}
