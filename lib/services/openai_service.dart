import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String apiKey;
  final String? organizationId; // Tambahkan parameter organization

  OpenAIService(this.apiKey, {this.organizationId}); // Tambahkan parameter opsional

  Future<List<String>> generateQuestionsWithPrompt(String prompt) async {
    try {
      // Validasi API key sebelum mengirim request
      if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
        throw Exception('API key tidak valid. Silakan periksa konfigurasi.');
      }

      // Siapkan headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      // Tambahkan header organization jika ada
      if (organizationId != null && organizationId!.isNotEmpty) {
        headers['OpenAI-Organization'] = organizationId!;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers, // Gunakan headers yang sudah disiapkan
        body: jsonEncode({
          'model': 'gpt-4-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      print('OpenAI Response Status: ${response.statusCode}');
      print('OpenAI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Clean the response content
        String cleanedContent = content.replaceAll('```json', '').replaceAll('```', '').trim();

        final List<dynamic> questionsJson = jsonDecode(cleanedContent);
        return questionsJson.map((q) => jsonEncode(q)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Autentikasi gagal. Periksa API key dan Organization ID Anda.');
      } else if (response.statusCode == 429) {
        throw Exception('Quota exceeded. Silakan coba lagi nanti atau periksa quota Anda.');
      } else {
        throw Exception('Failed to generate questions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in generateQuestionsWithPrompt: $e');
      rethrow;
    }
  }

  // Method untuk mengecek validitas API key dengan organization
  Future<bool> validateApiKey() async {
    try {
      // Siapkan headers
      Map<String, String> headers = {
        'Authorization': 'Bearer $apiKey',
      };

      // Tambahkan header organization jika ada
      if (organizationId != null && organizationId!.isNotEmpty) {
        headers['OpenAI-Organization'] = organizationId!;
      }

      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}