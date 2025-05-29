import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import '../../models/kupon_model.dart';
import 'kupon_state.dart';
import 'package:http/http.dart' as http;

class KuponBloc extends Bloc<KuponEvent, KuponState> {
  KuponBloc() : super(KuponInitial()) {
    on<Initial>(onInitial);
    on<FetchKupon>(onFetchKupon);
  }

  Future<void> onInitial(Initial event, Emitter<KuponState> emit) async{
    emit(KuponInitial());
  }

  Future<void> onFetchKupon(FetchKupon event, Emitter<KuponState> emit) async{
    emit(KuponLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/kupon/${event.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      print(response.body);
      final List<dynamic> data = json.decode(response.body);
      print(data);

      if (response.statusCode == 200) {
        final kupons = data.map((kupon) => KuponModel.fromJson(kupon)).toList();
        print(kupons);
        emit(KuponLoaded(kupons: kupons));
      } else {
        emit(KuponError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print(e);
      emit(KuponError(message: 'Error: $e'));
    }
  }
}