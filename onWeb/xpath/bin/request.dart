// dart pub add http
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // final url_ =
  // 'https://www.youtube.com/playlist?list=PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq';
  // final url_ ='https://reqbin.com/sample/post/json';
  // NOTE: videos in a playlist
  final url_ =
      'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&key=AIzaSyDvnsDZezmiT-x19yykQpzNISIFGLhV8vU&playlistId=PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq';
  final url = Uri.parse(url_);
  final response = await http.get(url);
  // final response = await http.post(url, body: {
  //   'key': 'value',
  // });

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  File('response.html').writeAsStringSync(response.body);
}
