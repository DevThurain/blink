import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

Future<void> generatePage(String pageName, String targetFolder) async {
  print('🔍 Searching for "$targetFolder" folder…');

  final targetDir = findTargetDirectory(Directory.current, targetFolder);

  if (targetDir == null) {
    print('❌ Could not find a "$targetFolder" folder in this project.');
    exit(1);
  }

  print('📂 Found $targetFolder folder: ${targetDir.path}');

  final basePageDir = Directory(p.join(targetDir.path, pageName));

  if (basePageDir.existsSync()) {
    print('⚠️ Page folder "$pageName" already exists.');
    exit(1);
  }

  // Create the folder structure
  final presentationDir = Directory(p.join(basePageDir.path, 'presentation'));
  final providersDir = Directory(p.join(basePageDir.path, 'providers'));

  presentationDir.createSync(recursive: true);
  providersDir.createSync(recursive: true);

  print('✅ Created directories:');
  print('  - ${presentationDir.path}');
  print('  - ${providersDir.path}');

  // Write files
  await _writeFromTemplate(
    'presentation_screen.dart.tpl',
    p.join(presentationDir.path, '${pageName}_screen.dart'),
    pageName,
  );

  await _writeFromTemplate(
    'providers_notifier.dart.tpl',
    p.join(providersDir.path, '${pageName}_notifier.dart'),
    pageName,
  );
}

Future<void> _writeFromTemplate(String templateName, String outputPath, String pageName) async {
  final templateContent = await _loadTemplateContent(templateName);

  var content = templateContent;
  final pascalName = _toPascalCase(pageName);
  final camelCaseName = _toCamelCase(pageName);
  final snakeCaseName = _toSnakeCase(pageName);

  content = content
      .replaceAll('{{page_name}}', pageName)
      .replaceAll('{{PascalCasePageName}}', pascalName)
      .replaceAll('{{CamelCasePageName}}', camelCaseName)
      .replaceAll('{{SnakeCasePageName}}', snakeCaseName);

  File(outputPath).writeAsStringSync(content);
  print('📝 Created file: $outputPath');
}

Future<String> _loadTemplateContent(String templateName) async {
  final uri = await Isolate.resolvePackageUri(Uri.parse('package:blink/templates/$templateName'));

  if (uri == null) {
    throw Exception('❌ Could not resolve template: $templateName');
  }

  final file = File(uri.toFilePath());
  if (!file.existsSync()) {
    throw Exception('❌ Template file does not exist: ${file.path}');
  }

  return await file.readAsString();
}

Directory? findTargetDirectory(Directory dir, String targetFolder) {
  for (final entity in dir.listSync()) {
    if (entity is Directory && p.basename(entity.path) == targetFolder) {
      return entity;
    }
  }

  for (final entity in dir.listSync()) {
    if (entity is Directory) {
      final found = findTargetDirectory(entity, targetFolder);
      if (found != null) return found;
    }
  }

  return null;
}

String _toPascalCase(String input) {
  return input.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

String _toCamelCase(String input) {
  final parts = input.split('_');
  return parts.first + parts.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
}

String _toSnakeCase(String input) {
  final buffer = StringBuffer();

  for (var i = 0; i < input.length; i++) {
    final char = input[i];

    if (_isUpperCase(char) && i != 0 && input[i - 1] != '_') {
      buffer.write('_');
    }

    buffer.write(char.toLowerCase());
  }

  return buffer.toString();
}

bool _isUpperCase(String char) => char != char.toLowerCase();

void initBlink() {
  final blinkDir = Directory(p.join(Directory.current.path, '.blink'));

  if (!blinkDir.existsSync()) {
    blinkDir.createSync(recursive: true);
    print('✅ Created .blink directory');
  } else {
    print('📂 .blink directory already exists');
  }

  final configFile = File(p.join(blinkDir.path, 'config.json'));

  if (!configFile.existsSync()) {
    final defaultConfig = {"router_path": "", "screen_exports": "", "app_routes": ""};

    configFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(defaultConfig));
    print('✅ Created default .blink/config.json');
  } else {
    print('📄 .blink/config.json already exists');
  }
}

