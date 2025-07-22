import 'dart:io';
import 'package:args/args.dart';
import 'package:blink/route_functions.dart';
import 'package:blink/generator.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  parser.addCommand('init');
  parser.addCommand('create:page');
  parser.addCommand('create:route');

  final argResults = parser.parse(arguments);

  switch (argResults.command?.name) {
    case 'init':
      _handleInit(argResults);
      break;

    case 'create:page':
      _handleCreatePage(argResults);
      break;

    case 'create:route':
      _handleCreateRoute(argResults);
      break;

    default:
      print('Unknown command ...');
      exit(1);
  }
}

_handleInit(ArgResults argResults) {
  initBlink();
}

_handleCreatePage(ArgResults argResults) {
  final args = argResults.command!.arguments;

  if (args.length != 3 || args[1] != 'on') {
    print('Usage: blink create:page <page_name> on <target_folder>');
    exit(1);
  }

  final pageName = args[0];
  final targetFolder = args[2];

  generatePage(pageName, targetFolder);
}

void _handleCreateRoute(ArgResults argResults) {
  final args = argResults.command!.rest;

  if (args.length != 1) {
    print('Usage: blink create:route <route_name>');
    exit(1);
  }

  final routeName = args[0];
  verifyConfig();

  print('✅ Config and required files verified.');
  print('🚀 You can now proceed to generate route: $routeName');
  addRouteToAppRoutes(routeName);
  addRouteToRouterPath(routeName);
  addRouteToScreenExports(routeName);
  // 👉 here you can add your route generation logic
}
