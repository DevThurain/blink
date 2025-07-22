import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class {{PascalCasePageName}}Screen extends HookConsumerWidget {
  const {{PascalCasePageName}}Screen({super.key});
  // final {{PascalCasePageName}}Params params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ref.easyListen({{CamelCasePageName}}NotifierProvider, whenData: (data) {});

    return Scaffold(
      body: const Text('{{PascalCasePageName}} Page')
    );
  }
}

// class {{PascalCasePageName}}Params {
//   final String param1;
//   final String param2;
//   {{PascalCasePageName}}Params({required this.param1, required this.param2});
// }
