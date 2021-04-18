import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:iapetus/iapetus.dart';
import 'package:pandora_authenticator/pandora_authenticator.dart'
    as pandora_authenticator;

Future<void> main(List<String> argumentStrings) async {
  // Parse the argument strings.
  final arguments = pandora_authenticator.Arguments(argumentStrings);

  // If the version should be shown, do that and exit.
  if (arguments.showVersion) {
    stdout.writeln(pandora_authenticator.displayInfo);
    exit(0);
  }

  // If the usage should be shown, do that and exit.
  if (arguments.showUsage) {
    stdout.writeln(pandora_authenticator.displayInfo);
    stdout.writeln();
    stdout.writeln(arguments.getUsage());
    exit(0);
  }

  // Retrieve the email address and password, and exit if they're missing and
  // won't be read from stdin.
  final email = arguments.email;
  final password = arguments.password;
  if (!arguments.interactive && (email == null || password == null)) {
    exit(_handleError(pandora_authenticator.Error.missingCredentials));
  }

  // Set up the Iapetus client using a memory-based storage implementation.
  final iapetus = Iapetus(
    fastStorage: MemoryIapetusStorage(),
    secureStorage: MemoryIapetusStorage(),
  );

  // Close the client on SIGINT.
  ProcessSignal.sigint.watch().first.then((_) async {
    await iapetus.close();
    exit(0);
  });

  // Perform a partner authentication, exiting when an error occurs.
  try {
    await iapetus.partnerLogin();
  } on SocketException {
    exit(_handleError(pandora_authenticator.Error.network));
  } on IapetusLocationException {
    exit(_handleError(pandora_authenticator.Error.location));
  }

  /// Logs in with the given [email] address and [password] and writes the
  /// authentication token to [stdout].
  ///
  /// Outputs errors to [stderr], and returns with an error code.
  Future<int> retrieveAuthToken(String email, String password) async {
    try {
      // Perform the login.
      await iapetus.userLogin(
        email: email,
        password: password,
        registerDevice: false,
      );
      // Write the authentication token to [stdout].
      stdout.writeln(iapetus.user.userAuthToken);
      return 0;
    } on SocketException {
      return _handleError(pandora_authenticator.Error.network);
    } on IapetusAuthenticationException {
      return _handleError(pandora_authenticator.Error.authentication);
    } on IapetusLocationException {
      return _handleError(pandora_authenticator.Error.location);
    }
  }

  if (arguments.interactive) {
    // If an interactive session is in use, continuously read credentials from
    // [stdin] and write authentication tokens to [stdout].
    final inputLineStream = stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .asBroadcastStream();
    while (true) {
      if (arguments.prompt) stdout.write('Email address: ');
      final email = await inputLineStream.first;
      if (arguments.prompt) stdout.write('Password: ');
      final password = await inputLineStream.first;
      if (arguments.prompt) stdout.writeln('Authenticating...');
      await retrieveAuthToken(email, password);
    }
  } else {
    // If an interactive session is not in use, retrieve the authentication
    // token once and then close the client and exit.
    final errorCode = await retrieveAuthToken(email!, password!);
    await iapetus.close();
    exit(errorCode);
  }
}

/// Writes the given [pandora_authenticator.Error] to [stderr], and returns its
/// error code.
int _handleError(pandora_authenticator.Error error) {
  stderr.writeln('ERROR ${error.errorCode}: ${error.message}');
  return error.errorCode;
}
