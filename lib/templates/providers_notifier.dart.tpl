import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{{SnakeCasePageName}}_notifier.g.dart';

@riverpod
class {{PascalCasePageName}}Notifier extends _${{PascalCasePageName}}Notifier {
  @override
  Future<Option<bool>> build() async {
    return none();
  }

  Future<void> method1() async {
    state = AsyncLoading();

    // final repo = ref.read(appRepositoryProvider);
    // state = await AsyncValue.guard(() async {
    //   final result = await repo.
    //   return some();
    // });
  }
}
