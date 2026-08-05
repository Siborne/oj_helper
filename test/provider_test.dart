import 'package:flutter_test/flutter_test.dart';
import 'package:oj_helper/provider.dart';

void main() {
  group('ContestProvider.toggleShowEmptyDay', () {
    test('按传入值设置状态而非简单取反（修复前忽略参数）', () {
      final p = ContestProvider();
      expect(p.showEmptyDay, isTrue);

      // 传入 false 应关闭
      p.toggleShowEmptyDay(false);
      expect(p.showEmptyDay, isFalse);
      // 再次传入 false 应保持关闭（旧实现取反会错误地重新打开）
      p.toggleShowEmptyDay(false);
      expect(p.showEmptyDay, isFalse);

      p.toggleShowEmptyDay(true);
      expect(p.showEmptyDay, isTrue);
    });
  });
}
