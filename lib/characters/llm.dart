import 'package:http/http.dart' as http;
import 'dart:convert';

class LLM {
  final String _apiKey =
      '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';

  Future<String> sendPostRequest(List<Map<String, String>> chatHistory) async {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'messages': chatHistory,
        'model': 'llama3-8b-8192',
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final responseContent =
            jsonResponse['choices'][0]['message']['content'];
        return responseContent;
      } else {
        return "Request failed with status: ${response.statusCode}";
      }
    } catch (e) {
      return "An error occurred: $e";
    }
  }
}
