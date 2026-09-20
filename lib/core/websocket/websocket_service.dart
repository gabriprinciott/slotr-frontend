import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:slotr_app/core/logging/app_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ConnectionStatus { connecting, connected, disconnected }

class WebSocketService {
  final String url;
  IO.Socket? _socket;
  final ValueNotifier<ConnectionStatus> status = ValueNotifier<ConnectionStatus>(ConnectionStatus.connecting);
  final StreamController<dynamic> _streamController = StreamController<dynamic>.broadcast();

  WebSocketService(this.url);

  void connect() {
    try {
      status.value = ConnectionStatus.connecting;
      final parsedUrl = url.replaceFirst('localhost', '127.0.0.1').replaceAll('ws://', 'http://').replaceAll('wss://', 'https://');
      log.d('Tentativo di connessione Socket.IO a $parsedUrl...');
      
      _socket = IO.io(parsedUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());

      _socket?.onConnect((_) {
        status.value = ConnectionStatus.connected;
        log.d('Socket.IO connesso');
      });

      _socket?.onDisconnect((_) {
        status.value = ConnectionStatus.disconnected;
        log.d('Socket.IO disconnesso');
      });
      
      _socket?.onConnectError((e) {
         status.value = ConnectionStatus.disconnected;
         _streamController.addError(e);
         log.w('Errore connessione Socket.IO: $e');
      });

      _socket?.onAny((event, data) {
         if (event == 'connect' || event == 'disconnect' || event == 'connect_error') return;
         if (data is Map) {
            data['type'] ??= event;
            _streamController.add(jsonEncode(data));
         } else if (data is String) {
            _streamController.add(data);
         } else {
            _streamController.add(jsonEncode({'type': event, 'data': data}));
         }
      });


      _socket?.on('SLOT_LOCKED', (data) {
         log.i('⚡ [RICEVUTO SLOT_LOCKED DIRETTO] $data');
         if (data is Map) {
             data['type'] = 'SLOT_LOCKED';
             _streamController.add(jsonEncode(data));
         }
      });

      _socket?.on('SLOT_UNLOCKED', (data) {
         log.i('⚡ [RICEVUTO SLOT_UNLOCKED DIRETTO] $data');
         if (data is Map) {
             data['type'] = 'SLOT_UNLOCKED';
             _streamController.add(jsonEncode(data));
         }
      });

      _socket?.connect();

    } catch (e) {
      log.w('Impossibile inizializzare il Socket.IO verso $url: $e');
      status.value = ConnectionStatus.disconnected;
    }
  }

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      status.value = ConnectionStatus.disconnected;
    } catch (_) {}
  }

  Stream<dynamic>? get stream => _streamController.stream;

  void send(String data) {
    if (_socket == null || status.value != ConnectionStatus.connected) {
      log.w('Tentativo di invio messaggio su Socket non connesso: $data');
      return;
    }
    try {
      final parsed = jsonDecode(data);
      if (parsed is Map && parsed.containsKey('type')) {
          final eventType = parsed['type'];
          _socket?.emit(eventType, parsed);
      } else {
          _socket?.emit('message', data);
      }
    } catch (e) {
      _socket?.emit('message', data);
    }
  }
}
