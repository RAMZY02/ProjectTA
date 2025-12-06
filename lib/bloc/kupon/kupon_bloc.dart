import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ta/bloc/kupon/kupon_event.dart';
import '../../models/kupon_model.dart';
import 'kupon_state.dart';
import 'package:http/http.dart' as http;

class KuponBloc extends Bloc<KuponEvent, KuponState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  KuponBloc() : super(KuponInitial()) {
    on<InitialKupon>(onInitial);
    on<FetchKupon>(onFetchKupon);
    on<FetchAllKupon>(onFetchAllKupon);
    on<ClaimKupon>(onClaimKupon);
    on<CreateKupon>(onCreateKupon);
  }

  Future<void> onInitial(InitialKupon event, Emitter<KuponState> emit) async{
    emit(KuponInitial());
  }

  Future<void> onFetchKupon(FetchKupon event, Emitter<KuponState> emit) async{
    emit(KuponLoading());
    final url = Uri.parse('$baseUrl/api/kupon/${event.userId}');
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

  Future<void> onFetchAllKupon(FetchAllKupon event, Emitter<KuponState> emit) async{
    emit(KuponLoading());
    final url = Uri.parse('$baseUrl/api/kupon');
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

  Future<void> onClaimKupon(ClaimKupon event, Emitter<KuponState> emit) async{
    emit(KuponLoading());
    final url = Uri.parse('$baseUrl/api/kupon/claim/${event.idKupon}');
    try {
      final response = await http.put(
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
        add(FetchAllKupon(token: event.token));
      } else {
        emit(KuponError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print(e);
      emit(KuponError(message: 'Error: $e'));
    }
  }

  Future<void> onCreateKupon(CreateKupon event, Emitter<KuponState> emit) async{
    final url = Uri.parse('$baseUrl/api/kupon');
    String randomString = generateRandomString();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_hadiah' : event.hadiah.id,
          'id_user' : event.userId,
          'kode' : randomString,
          'tipe' : event.hadiah.kategori
        })
      );

      print('ini bodynya create kupon');
      print(response.body);
      final data = json.decode(response.body);
      print(data);

      if (response.statusCode == 201) {
        final kupon = KuponModel.fromJson(data);
        print(kupon);
        emit(KuponInitial());
      } else {
        emit(KuponError(message: 'Failed to load kupons'));
      }
    } catch (e) {
      print("ini errornya create kupon");
      print(e);
      emit(KuponError(message: 'Error: $e'));
    }
  }
}

String generateRandomString() {
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  Random rnd = Random();

  return String.fromCharCodes(Iterable.generate(
      12,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length))
  ));
}