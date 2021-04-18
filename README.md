# Pandora Authenticator
A CLI tool to authenticate with Pandora and output an authentication token to be
used with their various APIs.

## Usage
To authenticate once: `pandora_authenticator <email address> <password>`

An interactive session can be started to authenticate multiple times efficiently.
See the usage information below for details.

```
Usage: pandora_authenticator [options] <email address> <password>

-v, --version        Show the tool version.
-h, --help           Show usage information.
-i, --interactive    Starts an interactive session. More efficient for multiple authentications than starting a new process each time.
-p, --[no-]prompt    Prompt for credentials through stdout in interactive mode. Disable to accept input without outputting prompts first. Useful for scripting.
                     (defaults to on)
```

### Exit codes
|Exit code|Description|
|---|---|
|`0`|No issues occurred.|
|`2`|Username and password arguments were required (for a non-interactive session), but none were provided.|
|`3`|There was a connection issue.|
|`4`|Invalid username or password.|
|`5`|A login was attempted from a place outside the US.|

## Building
The [Dart SDK](https://dart.dev/get-dart) is required for building.
Unfortunately, cross-compilation is [not yet possible](https://github.com/dart-lang/sdk/issues/28617).

```shell
dart pub get
dart compile exe bin/pandora_authenticator.dart
```

<!-- [UPX](https://upx.github.io) can be used to reduce the rather large executable size. -->
<!-- UPX does not work properly at the moment. -->