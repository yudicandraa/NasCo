import 'package:watermelon_sound/features/domain/entities/label.dart';

class PredictionModel extends PredictionEntity {
  const PredictionModel({required String label}) : super(label: label);

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      PredictionModel(
        label: json['predicted_label'],
      );

  PredictionEntity toEntity() => PredictionEntity(label: label);

  @override
  List<Object?> get props => [label];
}
