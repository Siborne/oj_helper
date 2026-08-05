import 'package:flutter_test/flutter_test.dart';
import 'package:oj_helper/utils/version_utils.dart';

void main() {
  group('VersionUtils.parseVersion', () {
    test('解析 v 前缀、缺段、build 后缀', () {
      expect(VersionUtils.parseVersion('v1.2.3'), [1, 2, 3]);
      expect(VersionUtils.parseVersion('2.9.4+1'), [2, 9, 4]);
      expect(VersionUtils.parseVersion('1.2'), [1, 2, 0]);
      expect(VersionUtils.parseVersion('v1'), [1, 0, 0]);
    });
  });

  group('VersionUtils.isNewer', () {
    test('正常版本递增', () {
      expect(VersionUtils.isNewer('v2.9.4', 'v2.8.0'), isTrue);
      expect(VersionUtils.isNewer('v1.2.3', 'v1.2.3'), isFalse);
      expect(VersionUtils.isNewer('v1.2.2', 'v1.2.3'), isFalse);
      expect(VersionUtils.isNewer('v1.2.3', 'v1.2.4'), isFalse);
    });

    test('跨主版本比较正确（旧实现字符串比较会误判 2.0.0 < 1.10.0）', () {
      // 旧的 replaceAll('.','') 会把 1.10.0 变成 "1100"、2.0.0 变成 "200"，
      // 导致"当前 2.0.0、最新 1.10.0"时错误提示降级更新
      expect(VersionUtils.isNewer('v1.10.0', 'v2.0.0'), isFalse);
      expect(VersionUtils.isNewer('v2.0.0', 'v1.10.0'), isTrue);
    });

    test('build 后缀与缺段', () {
      expect(VersionUtils.isNewer('v1.2', 'v1.1.9'), isTrue);
      expect(VersionUtils.isNewer('v1.2.3+1', 'v1.2.2'), isTrue);
      expect(VersionUtils.isNewer('v1.2.3+1', 'v1.2.3'), isFalse);
    });
  });
}
