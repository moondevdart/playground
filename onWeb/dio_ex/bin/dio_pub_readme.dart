// https://pub.dev/packages/dio
import 'dart:convert';
import 'package:dio/dio.dart';

main() async {
  final String url = 'https://velog.io/@leeeeeoy/Flutter-Dio-간단-정리';
  // final String url = 'http://www.google.com';
  try {
    var response = await Dio().get(url);
    // print(utf8.decode(response.data.bodyBytes));
    print(response.data);
  } catch (e) {
    print(e);
  }
}
