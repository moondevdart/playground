// dart pub add http
// import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'env.dart';

// Future<List<Map<String, dynamic>>> videosInPlaylist(
// Future<List<dynamic>>? videosInPlaylist(
Stream<dynamic>? videosInPlaylist(
    String part, String playlistId, int maxResults, String? pageToken) async* {
  final key = getKey();
  var items = <dynamic>[];
  var url =
      'https://www.googleapis.com/youtube/v3/playlistItems?part=$part&key=$key&playlistId=$playlistId&maxResults=${maxResults.toString()}';
  if (pageToken != null) {
    url += '&pageToken=$pageToken';
  }
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(response.body);
    while (body.containsKey('nextPageToken')) {
      // items.addAll(body['items']);
      // body = jsonDecode(await http.get(Uri.parse(url + '&pageToken=${body['nextPageToken']}')).body);
      videosInPlaylist(part, playlistId, maxResults, body['nextPageToken']);
      yield videosInPlaylist(
          part, playlistId, maxResults, body['nextPageToken']);
    }
    // if ("nextPageToken": "EAAaBlBUOkNBVQ") // TODO: 다음 페이지가 있는 경우 처리
    // List<Map<String, dynamic>> items = jsonDecode(response.body)['items'];

    // if (body.containsKey('nextPageToken')) {
    //   // NOTE: [yield, async*](https://cording-cossk3.tistory.com/90)
    //   videosInPlaylist(part, playlistId, maxResults, body['nextPageToken']);
    //   print('nextPageToken: ${body['nextPageToken']}');
    // }
    // List<dynamic> items = body['items'];
    // return body['items'];
  } else {
    yield [];
  }
}

void main() async {
  final response = await videosInPlaylist(
      'snippet', 'PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq', 2, null);
  print(response);

  // File('response.html').writeAsStringSync(response.body);
}
