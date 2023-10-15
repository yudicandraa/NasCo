import 'package:equatable/equatable.dart';

class PredictionEntity extends Equatable {
  const PredictionEntity({required this.label});

  final String label;

  @override
  List<Object?> get props => [label];
}
