
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project_ta/bloc/cloudflare/cloudflare_event.dart';
import 'package:project_ta/bloc/cloudflare/cloudflare_state.dart';

class CloudflareBloc extends Bloc<CloudflareEvent, CloudflareState> {
  CloudflareBloc() : super(CloudFlareInitial()) {
    on<UploadFile>(_onUploadFile);
  }

  Future<void> _onUploadFile(UploadFile event, Emitter<CloudflareState> emit) async {
    emit(CloudFlareLoading());

    try {
      // Buat multipart request
      var uri = Uri.parse('https://flounder-moved-rooster.ngrok-free.app/api/cloudflare');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan headers
      request.headers['Authorization'] = 'Bearer ${event.token}';

      // Tambahkan file
      request.files.add(await http.MultipartFile.fromPath(
        'fileContent', // Sesuai dengan nama field di backend
        event.fileContent.path,
        filename: event.fileName,
      ));

      // Tambahkan fields lain
      request.fields['fileName'] = event.fileName;
      request.fields['contentType'] = event.contentType;

      // Kirim request
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