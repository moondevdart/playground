// dart pub add http
// import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/secret.dart';

// import 'env.dart';

// Future<List<dynamic>> videoFutureInPlaylist(
//     String part, String playlistId, int maxResults, String? pageToken) async {
//   final key = getKey();
//   var url =
//       'https://www.googleapis.com/youtube/v3/playlistItems?part=$part&key=$key&playlistId=$playlistId&maxResults=${maxResults.toString()}';
//   if (pageToken != null) {
//     url += '&pageToken=$pageToken';
//   }
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     Map<String, dynamic> body = jsonDecode(response.body);
//     return body['items'];
//   } else {
//     return [];
//   }
// }

// Future<List<Map<String, dynamic>>> videosInPlaylist(
Stream<dynamic> videoStreamInPlaylist(
    String part, String playlistId, int maxResults, String? pageToken) async* {
  // final key = getKey();
  final key = Secret.API_KEY;
  var url =
      'https://www.googleapis.com/youtube/v3/playlistItems?part=$part&key=$key&playlistId=$playlistId&maxResults=${maxResults.toString()}';
  if (pageToken != null) {
    url += '&pageToken=$pageToken';
  }
  print(url);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(response.body);
    yield body['items'];
    if (body.containsKey('nextPageToken')) {
      yield* videoStreamInPlaylist(
          part, playlistId, maxResults, body['nextPageToken']);
    }
  } else {
    yield [];
  }
}

Future<dynamic> getVideosInPlaylist(Stream<dynamic> stream) async {
  List<dynamic> videoList = [];
  await for (var video in stream) {
    videoList.addAll(video);
  }
  return videoList;
}

void main() async {
  // // NOTE: print Future
  // final response = await videosInPlaylist(
  //     'snippet', 'PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq', 2, null);
  // print(response);

  // NOTE: print Stream
  List<dynamic> videoList = await getVideosInPlaylist(videoStreamInPlaylist(
      'snippet', 'PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq', 10, null));
  print(videoList);
  // File('response.html').writeAsStringSync(response.body);
}
