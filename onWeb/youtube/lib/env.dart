import 'package:dotenv/dotenv.dart';

String? getKey() {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  return env['key'];
}
