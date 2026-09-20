class ConfigurationException implements Exception {
  final String message;
  ConfigurationException([this.message = 'Configurazione dell\'applicazione non valida o mancante.']);

  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  ConflictException([this.message = 'conflict_error']);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'server_error']);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'network_error']);
  
  @override
  String toString() => message;
}

