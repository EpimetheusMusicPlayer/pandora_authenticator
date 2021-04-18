import 'dart:io';

import 'package:args/args.dart';

class Arguments {
  final bool showVersion;
  final bool showUsage;
  final bool interactive;
  final bool prompt;
  final String Function() getUsage;
  final String? email;
  final String? password;

  Arguments(Iterable<String> arguments)
      : this._fromParser(
          arguments,
          ArgParser()
            ..addFlag(
              'version',
              abbr: 'v',
              help: 'Show the tool version.',
              negatable: false,
            )
            ..addFlag(
              'help',
              abbr: 'h',
              help: 'Show usage information.',
              negatable: false,
            )
            ..addFlag(
              'interactive',
              abbr: 'i',
              help:
                  'Starts an interactive session. More efficient for multiple authentications than starting a new process each time.',
              negatable: false,
            )
            ..addFlag(
              'prompt',
              abbr: 'p',
              help:
                  'Prompt for credentials through stdout in interactive mode. Disable to accept input without outputting prompts first. Useful for scripting.',
              defaultsTo: true,
            ),
        );

  Arguments._fromParser(Iterable<String> arguments, ArgParser parser)
      : this._fromResults(parser, parser.parse(arguments));

  Arguments._fromResults(ArgParser parser, ArgResults results)
      : showVersion = results['version'] == true,
        showUsage = results['help'] == true,
        interactive = results['interactive'] == true,
        prompt = results['prompt'] == true,
        getUsage = (() =>
            'Usage: ${Platform.script.pathSegments.last} [options] <email address> <password>\n\n${parser.usage}'),
        email = results.rest.isNotEmpty ? results.rest[0] : null,
        password = results.rest.length >= 2 ? results.rest[1] : null;
}
