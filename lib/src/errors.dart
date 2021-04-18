class Error {
  final int errorCode;
  final String message;

  const Error._(this.errorCode, this.message);

  static const missingCredentials = Error._(2,
      'Please provide an email address and password (or use interactive mode).');

  static const network =
      Error._(3, 'There was an error connecting to Pandora.');

  static const authentication = Error._(4, 'Invalid credentials.');

  static const location = Error._(5, 'Non-US IP detected.');
}
