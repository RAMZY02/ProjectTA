// bloc/soal_ujian/soal_ujian_bloc.dart
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/soal_ujian/soal_ujian_event.dart';
import 'package:project_ta/bloc/soal_ujian/soal_ujian_state.dart';
import 'package:project_ta/models/soal_model.dart';

import '../../services/openai_service.dart';

class SoalUjianBloc extends Bloc<SoalUjianEvent, SoalUjianState> {

  final OpenAIService openAIService; // Tambahkan OpenAIService
  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';
  // final baseUrl = 'https://backend.srv1071909.hstgr.cloud';

  SoalUjianBloc({required this.openAIService}) : super(SoalUjianInitial()) {
    on<InitSoalUjian>(_onInit);
    on<FetchSoalUjian>(_onFetchSoalUjian);
    on<FetchSoalUjian2>(_onFetchSoalUjian2);
    on<FetchSoalUjian3>(_onFetchSoalUjian3);
    on<AddSoal>(_onAddSoal);
    on<UpdateSoal>(_onUpdateSoal);
    on<DeleteSoal>(_onDeleteSoal);
    // Tambahkan handler untuk event AI
    on<GenerateAISoal>(_onGenerateAISoal);
    on<SelectAISoal>(_onSelectAISoal);
    on<ClearAISoal>(_onClearAISoal);
  }

  Future<void> _onFetchSoalUjian(
    FetchSoalUjian event,
    Emitter<SoalUjianState> emit,
  ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal/${event.ujianId}/${event.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchSoalUjian2(
    FetchSoalUjian2 event,
    Emitter<SoalUjianState> emit,
  ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal/${event.ujianId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onFetchSoalUjian3(
      FetchSoalUjian3 event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal/urutan/${event.ujianId}/${event.userId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final soalList = data.map((soal) => SoalModel.fromJson(soal)).toList();
        emit(SoalUjianLoaded(soalList: soalList));
      }
      else if(response.statusCode == 404){
        emit(SoalUjianNotFound(message: "Belum Ada Soal Yang Terdaftar!"));
      }
      else {
        emit(SoalUjianError(message: 'Gagal memuat soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onInit(InitSoalUjian event, Emitter<SoalUjianState> emit) async {
    emit(SoalUjianInitial());
  }

  Future<void> _onAddSoal(
      AddSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian': event.soalData['id_ujian'],
          'tipe': event.soalData['tipe'],
          'soal': event.soalData['soal'],
          'opsi_a': event.soalData['opsi_a'],
          'opsi_b': event.soalData['opsi_b'],
          'opsi_c': event.soalData['opsi_c'],
          'opsi_d': event.soalData['opsi_d'],
          'opsi_e': event.soalData['opsi_e'],
          'jawaban': event.soalData['jawaban'],
          'pembahasan': event.soalData['pembahasan'],
          'link_video': event.soalData['link_video'],
          'link_gambar': event.soalData['link_gambar'],
          'link_audio': event.soalData['link_audio'],
          'link_video_pembahasan': event.soalData['link_video_pembahasan'],
          'link_gambar_pembahasan': event.soalData['link_gambar_pembahasan'],
          'link_audio_pembahasan': event.soalData['link_audio_pembahasan'],
        })
      );

      if (response.statusCode == 201) {
        add(FetchSoalUjian2(token: event.token, ujianId: int.parse(event.soalData['id_ujian'].toString())));
      }
      else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onUpdateSoal(
      UpdateSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal/${event.soalData['id']}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian': event.soalData['id_ujian'],
          'tipe': event.soalData['tipe'],
          'soal': event.soalData['soal'],
          'opsi_a': event.soalData['opsi_a'],
          'opsi_b': event.soalData['opsi_b'],
          'opsi_c': event.soalData['opsi_c'],
          'opsi_d': event.soalData['opsi_d'],
          'opsi_e': event.soalData['opsi_e'],
          'jawaban': event.soalData['jawaban'],
          'pembahasan': event.soalData['pembahasan'],
          'link_video': event.soalData['link_video'],
          'link_gambar': event.soalData['link_gambar'],
          'link_audio': event.soalData['link_audio'],
          'link_video_pembahasan': event.soalData['link_video_pembahasan'],
          'link_gambar_pembahasan': event.soalData['link_gambar_pembahasan'],
          'link_audio_pembahasan': event.soalData['link_audio_pembahasan'],
        })
      );

      if (response.statusCode == 200) {
        add(FetchSoalUjian2(token: event.token, ujianId: int.parse(event.soalData['id_ujian'].toString())));
      } else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  Future<void> _onDeleteSoal(
      DeleteSoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianLoading());
    final url = Uri.parse('$baseUrl/api/soal/delete/${event.id}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
        body: jsonEncode({
          'id_ujian' : event.id_ujian
        })
      );

      if (response.statusCode == 200) {
        emit(SoalUjianInitial());
        // add(FetchSoalUjian2(token: event.token, ujianId: event.id));
      } else {
        emit(SoalUjianError(message: 'Gagal add soal ujian'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  // Tambahkan method untuk GenerateAISoal
  Future<void> _onGenerateAISoal(
      GenerateAISoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianAILoading());
    try {
      String prompt;

      if (event.questionType == 'Pilihan Ganda') {
        prompt = '''
Buatkan 4 soal pilihan ganda untuk ujian dengan ketentuan berikut:
- Mata Pelajaran: ${event.subject}
- Topik: ${event.topic}
- Kelas: ${event.grade}
- Deskripsi: ${event.description}

Format setiap soal harus dalam bentuk JSON dengan struktur berikut:
{
  "soal": "pertanyaan",
  "opsi_a": "pilihan A",
  "opsi_b": "pilihan B", 
  "opsi_c": "pilihan C",
  "opsi_d": "pilihan D",
  "opsi_e": "pilihan E",
  "jawaban": "huruf jawaban benar (A-E) harus huruf besar, harus sinkron antara hasil akhir pada pembahasan dengan opsi jawaban benar",
  "pembahasan": "penjelasan mengapa jawaban tersebut benar"
}
''';
      } else {
        prompt = '''
Buatkan 4 soal ${event.questionType.toLowerCase()} untuk ujian dengan ketentuan berikut:
- Mata Pelajaran: ${event.subject}
- Topik: ${event.topic}
- Kelas: ${event.grade}
- Deskripsi: ${event.description}

Format setiap soal harus dalam bentuk JSON dengan struktur berikut:
{
  "soal": "pertanyaan",
  "pembahasan": "penjelasan jawaban yang benar"
}
''';
      }

      prompt += '\nKembalikan hanya array JSON dengan 4 objek soal, tanpa teks tambahan lainnya.';

      final aiQuestions = await openAIService.generateQuestionsWithPrompt(prompt);

      final aiSoalList = aiQuestions.map((jsonString) {
        final data = jsonDecode(jsonString);
        return SoalModel(
          id: 0,
          idUjian: 0,
          tipe: event.questionType,
          soal: data['soal'],
          opsiA: event.questionType == 'Pilihan Ganda' ? data['opsi_a'] ?? '-' : '-',
          opsiB: event.questionType == 'Pilihan Ganda' ? data['opsi_b'] ?? '-' : '-',
          opsiC: event.questionType == 'Pilihan Ganda' ? data['opsi_c'] ?? '-' : '-',
          opsiD: event.questionType == 'Pilihan Ganda' ? data['opsi_d'] ?? '-' : '-',
          opsiE: event.questionType == 'Pilihan Ganda' ? data['opsi_e'] ?? '-' : '-',
          jawaban: event.questionType == 'Pilihan Ganda' ? data['jawaban'].toString().toUpperCase() ?? '-' : '-',
          pembahasan: data['pembahasan'] ?? '',
          linkVideo: '-',
          linkGambar: '-',
          linkAudio: '-',
          linkVideoPembahasan: '-',
          linkGambarPembahasan: '-',
          linkAudioPembahasan: '-',
          jawabanSiswa: '-',
          nilaiSiswa: 0,
        );
      }).toList();

      emit(SoalUjianAILoaded(aiSoalList));
    } catch (e) {
      emit(SoalUjianAIError(e.toString()));
    }
  }

  // Tambahkan method untuk SelectAISoal
  Future<void> _onSelectAISoal(
      SelectAISoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    final url = Uri.parse('$baseUrl/api/soal');
    try {
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${event.token}',
          },
          body: jsonEncode({
            'id_ujian': event.selectedSoal.idUjian,
            'tipe': event.selectedSoal.tipe,
            'soal': event.selectedSoal.soal,
            'opsi_a': event.selectedSoal.opsiA,
            'opsi_b': event.selectedSoal.opsiB,
            'opsi_c': event.selectedSoal.opsiC,
            'opsi_d': event.selectedSoal.opsiD,
            'opsi_e': event.selectedSoal.opsiE,
            'jawaban': event.selectedSoal.jawaban,
            'pembahasan': event.selectedSoal.pembahasan,
            'link_video': event.selectedSoal.linkVideo,
            'link_gambar': event.selectedSoal.linkGambar,
            'link_audio': event.selectedSoal.linkAudio,
            'link_video_pembahasan': event.selectedSoal.linkVideoPembahasan,
            'link_gambar_pembahasan': event.selectedSoal.linkGambarPembahasan,
            'link_audio_pembahasan': event.selectedSoal.linkAudioPembahasan,
          })
      );

      if (response.statusCode == 201) {
      } else {
        emit(SoalUjianError(message: 'Gagal menambahkan soal AI'));
      }
    } catch (e) {
      emit(SoalUjianError(message: 'Error: $e'));
    }
  }

  // Tambahkan method untuk ClearAISoal
  Future<void> _onClearAISoal(
      ClearAISoal event,
      Emitter<SoalUjianState> emit,
      ) async {
    emit(SoalUjianInitial());
  }
}
