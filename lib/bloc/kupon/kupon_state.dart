import 'package:project_ta/models/kupon_model.dart';

abstract class KuponState {}

class KuponInitial extends KuponState {}

class KuponLoading extends KuponState{}

class KuponLoaded extends KuponState{

  final List<KuponModel> kupons;

  KuponLoaded({required this.kupons});
}

class KuponError extends KuponState{
  String message;

  KuponError({required this.message});
}