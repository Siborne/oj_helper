import 'package:flutter_test/flutter_test.dart';
import 'package:oj_helper/services/recent_contest_services.dart';

void main() {
  // 今天零点 = 1000（用假值测纯逻辑）
  const midnight = 1000;
  const queryWindow = 7 * 24 * 60 * 60;

  group('RecentContestServices.isInTime', () {
    test('进行中的比赛返回 0', () {
      expect(
        RecentContestServices.isInTime(
          startTime: midnight - 100,
          duration: 7200,
          queryEndSeconds: queryWindow,
          midnightSeconds: midnight,
        ),
        0,
      );
    });

    test('开始过晚（超过 7 天窗口）返回 1', () {
      expect(
        RecentContestServices.isInTime(
          startTime: midnight + queryWindow + 1,
          duration: 7200,
          queryEndSeconds: queryWindow,
          midnightSeconds: midnight,
        ),
        1,
      );
    });

    test('已结束（结束时刻早于今天零点）返回 2', () {
      expect(
        RecentContestServices.isInTime(
          startTime: midnight - 7200,
          duration: 7200,
          queryEndSeconds: queryWindow,
          midnightSeconds: midnight,
        ),
        2,
      );
    });

    test('跨天进行中的长比赛（>24h）不被过滤（修复前会误返回 1）', () {
      // 例如 AtCoder Heuristic 一周赛：今天零点开始、持续 7 天
      expect(
        RecentContestServices.isInTime(
          startTime: midnight,
          duration: 7 * 24 * 60 * 60,
          queryEndSeconds: queryWindow,
          midnightSeconds: midnight,
        ),
        0,
      );
    });

    test('窗口边界：开始时间恰好在窗口内返回 0', () {
      expect(
        RecentContestServices.isInTime(
          startTime: midnight + queryWindow,
          duration: 3600,
          queryEndSeconds: queryWindow,
          midnightSeconds: midnight,
        ),
        0,
      );
    });
  });
}
