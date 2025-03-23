import 'dart:async';

class ReverbOptions {
  final String scheme;
  final String host;
  final String port;
  final String appKey;
  // final dynamic authToken;
  final FutureOr<String>? authToken;
  final String? authUrl;
  final String privatePrefix;
  final bool usePrefix;

  ReverbOptions({
    required this.scheme,
    required this.host,
    required this.port,
    required this.appKey,
    this.authToken,
    this.authUrl,
    this.privatePrefix = 'private-',
    this.usePrefix = true,
  });

  // Map<String, dynamic> toJson() {
  //   return {
  //     "scheme": scheme,
  //     "host": host,
  //     "port": port,
  //     "appKey": appKey,
  //     "authUrl": authUrl,
  //     "privatePrefix": privatePrefix,
  //   };
  // }
}

enum Scheme {
  ws('ws'),
  wss('wss');

  final String name;
  const Scheme(this.name);
}
