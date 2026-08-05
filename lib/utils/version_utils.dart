///语义化版本号比较工具（供设置页检查更新与单元测试使用）
class VersionUtils {
  /// 解析版本号 "v1.2.3" / "1.2.3+1" -> [1,2,3]，缺段补 0，忽略 "+build" 后缀
  static List<int> parseVersion(String version) {
    final cleaned = version.replaceFirst(RegExp(r'^[vV]'), '');
    final parts = cleaned.split('.');
    final result = <int>[];
    for (final p in parts) {
      result.add(int.tryParse(p.split('+').first.trim()) ?? 0);
    }
    while (result.length < 3) {
      result.add(0);
    }
    return result;
  }

  /// latest 是否比 current 新（按段比较，避免 "2.0.0" < "1.10.0" 之类的字符串误判）
  static bool isNewer(String latest, String current) {
    final a = parseVersion(latest);
    final b = parseVersion(current);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av > bv;
    }
    return false;
  }
}
