class ApiException implements Exception {
  final String message;
  ApiException([this.message = 'An unknown error occurred']);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized'])
      : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException([String message = 'Access forbidden'])
      : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
      : super(message);
}

class ServerException extends ApiException {
  ServerException([String message = 'Server error'])
      : super(message);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network error'])
      : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timeout'])
      : super(message);
}