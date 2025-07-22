import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

/// Add Route to app_routes.dart
void verifyConfig() {
  final configFile = File('.blink/config.json');

  if (!configFile.existsSync()) {
    print('❌ .blink/config.json not found. Please run `blink init` first.');
    exit(1);
  }

  final jsonStr = configFile.readAsStringSync();
  final config = jsonDecode(jsonStr);

  final routerPath = config['router_path'] as String?;
  final screenExports = config['screen_exports'] as String?;
  final appRoutes = config['app_routes'] as String?;

  if (routerPath == null || routerPath.isEmpty) {
    print('❌ "router_path" is missing or empty in .blink/config.json');
    exit(1);
  }
  if (screenExports == null || screenExports.isEmpty) {
    print('❌ "screen_exports" is missing or empty in .blink/config.json');
    exit(1);
  }
  if (appRoutes == null || appRoutes.isEmpty) {
    print('❌ "app_routes" is missing or empty in .blink/config.json');
    exit(1);
  }

  if (!File(routerPath).existsSync()) {
    print('❌ router_path file not found: $routerPath');
    exit(1);
  }
  if (!File(screenExports).existsSync()) {
    print('❌ screen_exports file not found: $screenExports');
    exit(1);
  }
  if (!File(appRoutes).existsSync()) {
    print('❌ app_routes file not found: $appRoutes');
    exit(1);
  }
}

void addRouteToAppRoutes(String routeName) {
  // Read config
  final configFile = File('.blink/config.json');

  if (!configFile.existsSync()) {
    print('❌ .blink/config.json not found. Run `blink init` first.');
    exit(1);
  }

  final config = jsonDecode(configFile.readAsStringSync());
  final appRoutesPath = config['app_routes'] as String?;

  if (appRoutesPath == null || appRoutesPath.isEmpty) {
    print('❌ "app_routes" is missing or empty in .blink/config.json');
    exit(1);
  }

  final file = File(appRoutesPath);

  if (!file.existsSync()) {
    print('❌ app_routes.dart not found at: $appRoutesPath');
    exit(1);
  }

  final content = file.readAsStringSync();

  final buffer = StringBuffer();

  final routeConst = "  static const ${routeName}_screen = '/${routeName}_screen';";

  // Check if it already exists
  if (content.contains("${routeName}_screen")) {
    print('⚠️ Route "${routeName}_screen" already exists in app_routes.dart');
    return;
  }

  final lines = content.split('\n');

  bool added = false;

  for (var line in lines) {
    // before the closing brace of AppRoutes
    if (line.trim() == '}') {
      buffer.writeln(routeConst);
      buffer.writeln();
      added = true;
    }
    buffer.writeln(line);
  }

  if (!added) {
    print('❌ Failed to find closing brace in app_routes.dart');
    exit(1);
  }

  file.writeAsStringSync(buffer.toString());
  print('✅ Added route "${routeName}_screen" to app_routes.dart');
}

/// Add Route to router.dart
void addRouteToRouterPath(String screenName) {
  final configFile = File('.blink/config.json');

  if (!configFile.existsSync()) {
    print('❌ .blink/config.json not found. Run `blink init` first.');
    exit(1);
  }

  final config = jsonDecode(configFile.readAsStringSync());
  final routerPath = config['router_path'] as String?;

  if (routerPath == null || routerPath.isEmpty) {
    print('❌ "router_path" is missing or empty in .blink/config.json');
    exit(1);
  }

  final file = File(routerPath);

  if (!file.existsSync()) {
    print('❌ router_path.dart not found at: $routerPath');
    exit(1);
  }

  final content = file.readAsStringSync();

  final buffer = StringBuffer();

  final routeCode = '''
    GoRoute(
      path: AppRoutes.${screenName}_screen,
      name: AppRoutes.${screenName}_screen,
      pageBuilder: (context, state) => CupertinoPage(child: ${_snaketoPascalCase(screenName)}Screen()),
    ),
''';

  if (content.contains("AppRoutes.${screenName}_screen")) {
    print('⚠️ Route "${screenName}_screen" already exists in router.');
    return;
  }

  final lines = content.split('\n');

  bool insideRoutesBlock = false;
  bool added = false;

  for (var line in lines) {
    // Detect the start of routes:
    if (line.contains('routes:')) {
      insideRoutesBlock = true;
    }

    // When inside routes block, look for closing ],
    if (insideRoutesBlock && !added && line.trim() == '],') {
      buffer.writeln(routeCode);
      added = true;
    }

    buffer.writeln(line);
  }

  if (!added) {
    print('❌ Could not find the `routes:` section to insert route.');
    exit(1);
  }

  file.writeAsStringSync(buffer.toString());
  print('✅ Added route "${screenName}_screen" to router.');
}

String _snaketoPascalCase(String input) {
  return input.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join();
}

/// Add Route to screen_export.dart */
/// Adds an `export` of `<screenName>_screen.dart` to the `screen_exports.dart` file,
/// by finding the file and writing the proper package path.
void addRouteToScreenExports(String screenName) {
  final configFile = File('.blink/config.json');

  if (!configFile.existsSync()) {
    print('❌ .blink/config.json not found. Run `blink init` first.');
    exit(1);
  }

  final config = jsonDecode(configFile.readAsStringSync());
  final screenExportsPath = config['screen_exports'] as String?;

  if (screenExportsPath == null || screenExportsPath.isEmpty) {
    print('❌ "screen_exports" is missing or empty in .blink/config.json');
    exit(1);
  }

  final screenExportsFile = File(screenExportsPath);

  if (!screenExportsFile.existsSync()) {
    print('❌ screen_exports.dart not found at: $screenExportsPath');
    exit(1);
  }

  final screenFilePath = _findScreenFile(screenName);

  if (screenFilePath == null) {
    print('❌ Could not find file: ${screenName}_screen.dart in the project.');
    exit(1);
  }

  final packageName = _getPackageName();

  if (packageName == null) {
    print('❌ Could not determine project name from pubspec.yaml.');
    exit(1);
  }

  final packagePath = _convertToPackagePath(screenFilePath, packageName);

  if (packagePath == null) {
    print('❌ Failed to convert path to package: path: $screenFilePath');
    exit(1);
  }

  final exportLine = "export '$packagePath';";

  final content = screenExportsFile.readAsStringSync();

  if (content.contains(exportLine)) {
    print('⚠️ ${screenName}_screen.dart is already exported in screen_exports.dart');
    return;
  }

  screenExportsFile.writeAsStringSync('${content.trimRight()}\n$exportLine\n');

  print('✅ Added ${screenName}_screen.dart to screen_exports.dart');
}

/// Recursively searches for `<screenName>_screen.dart` starting at project root
String? _findScreenFile(String screenName) {
  final currentDir = Directory.current;

  final files = currentDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => p.basename(f.path) == '${screenName}_screen.dart');

  if (files.isEmpty) return null;

  return files.first.path;
}

/// Reads the `name:` from pubspec.yaml in project root
String? _getPackageName() {
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) return null;

  final lines = pubspecFile.readAsLinesSync();

  for (var line in lines) {
    if (line.trim().startsWith('name:')) {
      return line.split(':').last.trim();
    }
  }

  return null;
}

/// Converts a file path (inside lib/) to a `package:` import path
String? _convertToPackagePath(String filePath, String packageName) {
  final normalizedPath = p.normalize(filePath);
  final libIndex = normalizedPath.indexOf('lib${p.separator}');
  if (libIndex == -1) return null;

  final relativePath = normalizedPath.substring(libIndex + 4); // after `lib/`
  return 'package:$packageName/${relativePath.replaceAll(r'\', '/')}';
}
