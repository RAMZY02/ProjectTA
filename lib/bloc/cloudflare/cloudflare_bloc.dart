
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/cloudflare/cloudflare_event.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_state.dart';

class CloudflareBloc extends Bloc<CloudflareEvent, CloudflareState> {

  // final baseUrl = 'http://localhost:3000';
  final baseUrl = 'https://flounder-moved-rooster.ngrok-free.app';

  CloudflareBloc() : super(CloudFlareInitial()) {
    on<UploadFile>(_onUploadFile);
  }

  // Modifikasi di CloudflareBloc
  Future<void> _onUploadFile(UploadFile event, Emitter<CloudflareState> emit) async {
    emit(CloudFlareLoading());

    try {
      var uri = Uri.parse('$baseUrl/api/cloudflare');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer ${event.token}';

      // Modifikasi untuk support web dan mobile
      if (kIsWeb) {
        // Untuk web: baca file sebagai bytes
        final bytes = event.fileWeb;
        request.files.add(http.MultipartFile.fromBytes(
          'fileContent',
          bytes as List<int>,
          filename: event.fileName,
        ));
      } else {
        // Untuk mobile: gunakan fromPath seperti sebelumnya
        request.files.add(await http.MultipartFile.fromPath(
          'fileContent',
          event.fileContent!.path,
          filename: event.fileName,
        ));
      }

      request.fields['fileName'] = event.fileName;
      request.fields['contentType'] = event.contentType;

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        emit(CloudFlareLoaded(fileName: event.fileName));
        print('Upload berhasil: $responseBody');
      } else {
        emit(CloudFlareError(message: 'Upload gagal: ${response.statusCode}'));
      }
    } catch (e) {
      emit(CloudFlareError(message: 'Error: $e'));
    }
  }
}