import 'dart:convert';

import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:shared_preferences/shared_preferences.dart';

///收藏数据的存储工具。
///
///统一使用 JSON 数组格式存储比赛信息和收藏名称列表，避免比赛名含逗号
///时旧"逗号分隔"格式导致的字段错位/崩溃；同时兼容读取旧格式数据。
class FavoriteUtils {
  ///读取收藏名称列表，兼容旧格式（逗号分隔）
  static List<String> getFavoriteNames(SharedPreferences prefs) {
    final cur = prefs.getString('favourite_contests');
    if (cur == null || cur.isEmpty) return [];
    try {
      final decoded = jsonDecode(cur);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // 旧格式，走逗号分隔
    }
    return cur.split(',').where((e) => e.isNotEmpty).toList();
  }

  ///序列化比赛为 JSON 存储串（不再用逗号分隔，避免名字中的逗号破坏数据）
  static String encodeContest(
    String name,
    int startTimeSeconds,
    int durationSeconds,
    String platform,
    String? link,
  ) {
    return jsonEncode([
      name,
      startTimeSeconds,
      durationSeconds,
      platform,
      link,
    ]);
  }

  ///从存储数据解析 Contest（兼容 JSON / 旧逗号两种格式），解析失败返回 null
  static Contest? parseStoredContest(String infor) {
    try {
      final decoded = jsonDecode(infor);
      if (decoded is List && decoded.length >= 4) {
        final link = decoded.length > 4 &&
                decoded[4] != null &&
                decoded[4].toString().isNotEmpty
            ? decoded[4].toString()
            : null;
        return Contest.fromJson(
          decoded[0].toString(),
          (decoded[1] as num).toInt(),
          (decoded[2] as num).toInt(),
          decoded[3].toString(),
          link,
        );
      }
    } catch (_) {
      // 不是 JSON，走旧格式
    }
    // 兼容旧格式：逗号分隔
    final inforList = infor.split(',');
    if (inforList.length < 4) return null;
    final start = int.tryParse(inforList[1]);
    final duration = int.tryParse(inforList[2]);
    if (start == null || duration == null) return null;
    final link = inforList.length > 4 && inforList[4].isNotEmpty
        ? inforList[4]
        : null;
    return Contest.fromJson(
      inforList[0],
      start,
      duration,
      inforList[3],
      link,
    );
  }
}
