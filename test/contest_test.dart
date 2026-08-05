import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:oj_helper/models/contest.dart';

void main() {
  group('Contest.fromJson', () {
    test('格式化开始/结束时间、时长与链接', () {
      // 本地时间 2024-06-29 20:00 对应的时间戳秒
      final start = DateTime(2024, 6, 29, 20, 0).millisecondsSinceEpoch ~/ 1000;
      final contest = Contest.fromJson(
          '测试赛', start, 7200, 'AtCoder', 'https://example.com');

      final fmt = DateFormat('yyyy-MM-dd HH:mm');
      expect(contest.startTime, fmt.format(DateTime(2024, 6, 29, 20, 0)));
      expect(contest.endTime, fmt.format(DateTime(2024, 6, 29, 22, 0)));
      expect(contest.duration, '2 小时 0 分钟');
      expect(contest.platform, 'AtCoder');
      expect(contest.link, 'https://example.com');
      expect(contest.startTimeSeconds, start);
      expect(contest.durationSeconds, 7200);
    });

    test('跨天比赛结束时间正确', () {
      // 23:00 开始，3 小时后结束（次日 02:00）
      final start = DateTime(2024, 6, 29, 23, 0).millisecondsSinceEpoch ~/ 1000;
      final contest = Contest.fromJson('深夜赛', start, 3 * 3600, '牛客', null);

      final fmt = DateFormat('yyyy-MM-dd HH:mm');
      expect(contest.startTime, fmt.format(DateTime(2024, 6, 29, 23, 0)));
      expect(contest.endTime, fmt.format(DateTime(2024, 6, 30, 2, 0)));
      expect(contest.duration, '3 小时 0 分钟');
      expect(contest.link, isNull);
    });
  });
}
