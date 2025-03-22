import 'package:flutter_websockets/reverb/flutter_reverb.dart';
import 'package:flutter_websockets/reverb/reverb_options.dart';

class WebsocketService {
  late FlutterReverb _flutterReverb;

  static final WebsocketService _instance = WebsocketService._internal();

  WebsocketService._internal();

  factory WebsocketService.init(ReverbOptions options) {
    _instance._flutterReverb = FlutterReverb(options: options);
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

  void notifications({required Function(WebsocketResponse data) onData}) {
    listenPrivateChannel(
      onData: onData,
      channelName:
          '.Illuminate\\Notifications\\Events\\BroadcastNotificationCreated',
    );
  }

  void close(){
    _flutterReverb.close();
  }
}
