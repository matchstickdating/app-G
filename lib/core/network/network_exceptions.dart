/// Match Stick Network & Service Exceptions
/// 
/// Core Rule: Never expose technical stack traces or database errors to the user.
/// Present calm, human copy while capturing debug details internally.
class MatchException implements Exception {
  final String userMessage;
  final String? technicalDetails;
  final int? statusCode;

  const MatchException({
    required this.userMessage,
    this.technicalDetails,
    this.statusCode,
  });

  factory MatchException.fromError(dynamic error) {
    if (error is MatchException) return error;

    final errStr = error.toString().toLowerCase();

    if (errStr.contains('socketexception') || errStr.contains('network') || errStr.contains('failed host lookup')) {
      return MatchException(
        userMessage: 'it looks like you\'re offline. check your connection.',
        technicalDetails: error.toString(),
      );
    }

    if (errStr.contains('invalid login credentials') || errStr.contains('invalid_grant')) {
      return MatchException(
        userMessage: 'we couldn\'t find a match for that email and password.',
        technicalDetails: error.toString(),
        statusCode: 401,
      );
    }

    if (errStr.contains('user already registered') || errStr.contains('unique constraint')) {
      return MatchException(
        userMessage: 'an account with this email already exists.',
        technicalDetails: error.toString(),
        statusCode: 409,
      );
    }

    if (errStr.contains('jwt expired') || errStr.contains('token is expired')) {
      return MatchException(
        userMessage: 'your session has expired. please sign in again.',
        technicalDetails: error.toString(),
        statusCode: 401,
      );
    }

    return MatchException(
      userMessage: 'something went sideways. try again in a moment.',
      technicalDetails: error.toString(),
    );
  }

  @override
  String toString() => 'MatchException(userMessage: $userMessage, technical: $technicalDetails)';
}
