import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/hadiah_model.dart';
import 'hadiah_event.dart';
import 'hadiah_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HadiahBloc extends Bloc<HadiahEvent, HadiahState>{
  HadiahBloc() : super(HadiahInitial()) {
    on<Inits>(_onInit);
    on<FetchHadiah>(_onFetch);
    on<TukarHadiah>(_onTukarHadiah);
    on<AddHadiah>(_onAddHadiah);
    on<UpdateHadiah>(_onUpdateHadiah);
    on<DeleteHadiah>(_onDeleteHadiah);
  }

  Future<void> _onInit(Inits event, Emitter<HadiahState> emit) async {
    emit(HadiahInitial());
  }

  Future<void> _onFetch(FetchHadiah event, Emitter<HadiahState> emit) async{
    emit(HadiahLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/hadiah');
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
        final hadiah = data.map((temp) => HadiahModel.fromJson(temp)).toList();
        print(hadiah);
        emit(HadiahLoaded(hadiah: hadiah));
      } else {
        emit(HadiahError(message: 'Failed to load hadiah'));
      }
    } catch (e) {
      print(e);
      emit(HadiahError(message: 'Error: $e'));
    }
  }

  Future<void> _onTukarHadiah(TukarHadiah event, Emitter<HadiahState> emit) async{
    emit(HadiahLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/hadiah/tukar-hadiah');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'userId' : event.userId,
          'hadiahId' : event.hadiahId,
        })
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final updatedHadiah = HadiahModel.fromJson(responseData['hadiah']);

        final updatedHadiahs = event.hadiah.map((hadiah) {
          return hadiah.id == updatedHadiah.id ? updatedHadiah : hadiah;
        }).toList();
        emit(HadiahLoaded(hadiah: updatedHadiahs));
      } else {
        emit(HadiahError(message: 'Failed to load hadiah'));
      }
    } catch (e) {
      print(e);
      emit(HadiahError(message: 'Error: $e'));
    }
  }

  Future<void> _onAddHadiah(AddHadiah event, Emitter<HadiahState> emit) async{
    emit(HadiahLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/hadiah');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'nama' : event.nama,
          'poin' : event.poin,
          'stok' : event.stok,
          'link_gambar': event.linkGambar,
          'kategori': event.kategori,
        })
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        add(FetchHadiah(token: event.token));
      } else {
        emit(HadiahError(message: 'Failed to add hadiah'));
      }
    } catch (e) {
      print(e);
      emit(HadiahError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateHadiah(UpdateHadiah event, Emitter<HadiahState> emit) async{
    emit(HadiahLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/hadiah/${event.hadiahId}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'nama' : event.nama,
          'poin' : event.poin,
          'stok' : event.stok,
          'link_gambar': event.linkGambar,
          'kategori': event.kategori,
        })
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        add(FetchHadiah(token: event.token));
      } else {
        emit(HadiahError(message: 'Failed to load hadiah'));
      }
    } catch (e) {
      print(e);
      emit(HadiahError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteHadiah(DeleteHadiah event, Emitter<HadiahState> emit) async{
    emit(HadiahLoading());
    final url = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/hadiah/delete/${event.hadiahId}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        add(FetchHadiah(token: event.token));
      } else {
        emit(HadiahError(message: 'Failed to load hadiah'));
      }
    } catch (e) {
      print(e);
      emit(HadiahError(message: 'Error: $e'));
    }
  }
}