import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/flutter_reverb_revisted.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';

/// Usage Example
///```
///final options = ReverbOptions(
///    scheme: "ws",
///    host: reverbHost,
///    port: "$reverbPort",
///    appKey: reverbAppKey,
///    authUrl:
///        "http://$reverbHost/broadcasting/auth", // optional, needed for private channels
///    authToken: "your-auth-token", // optional
///    privatePrefix: "private-", // default: "private-"
///    usePrefix: true, // default: true
///  );
///
/// final websocket = WebsocketService.init(options);
///
/// websocket.listenChannel(
///   channelName: 'sent-messages',
///   onData: (response) {
///     logger.i("Received: ${response.event}, Data: ${response.data}");
///     logger.e("Received: ${response.toJson()}");
///     setState(() {
///       data = response.data;
///     });
///   },
/// );
/// ```
class WebsocketService {
  late FlutterReverbImp _flutterReverb;
  // late FlutterReverb _flutterReverb;

  static final WebsocketService _instance = WebsocketService._internal();

  WebsocketService._internal();

  factory WebsocketService.init(ReverbOptions options) {
    _instance._flutterReverb = FlutterReverbImp(options: options);
    // _instance._flutterReverb = FlutterReverb(options: options);
    return _instance;
  }

  void listenPrivateChannel({
    required String channelName,
    required Function(WebsocketResponse data) onData,
  }) {
    _flutterReverb.listen(onData, channelName, isPrivate: true);
  }

  void listenChannel({
    required String channelName,
    required Function(WebsocketResponse data) onData,
  }) {
    _flutterReverb.listen(onData, channelName, isPrivate: false);
  }

  void notifications(Function(WebsocketResponse data) onData) {
    listenPrivateChannel(
      onData: onData,
      channelName:
          '.Illuminate\\Notifications\\Events\\BroadcastNotificationCreated',
    );
  }

  WebsocketService channel(String channelName) {
    _flutterReverb.channel(channelName);
    return this;
  }

  WebsocketService private(String channelName) {
    _flutterReverb.private(channelName);
    return this;
  }

  void listen(void Function(WebsocketResponse data) onData) {
    return _flutterReverb.stream(onData);
  }

  void close() {
    _flutterReverb.close();
  }

  void reconnect() {
    _flutterReverb.reconnect();
  }
}
