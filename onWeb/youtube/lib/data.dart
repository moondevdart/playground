// dart pub add http
// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'models/videos_list.dart';
import 'services/youtube_api.dart';

void main() async {
  VideosList videoList = await YoutubeAPI.getVideosList(
      playListId: 'PLgRxBCVPaZ_1iBe1v3-ZSSzHGdQo7AZPq', pageToken: '');
  print(videoList.videos![5].video!.title);
}
