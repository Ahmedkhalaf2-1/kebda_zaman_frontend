import 'package:http/http.dart' as http;
void main() async {
  try {
    final r = await http.get(Uri.parse('http://192.168.1.51:3000/api/v1/health'));
    print('Status: ${r.statusCode}');
    print('Body: ${r.body}');
  } catch (e) {
    print('Error: $e');
  }
}
