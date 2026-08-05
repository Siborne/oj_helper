import 'package:flutter_test/flutter_test.dart';
import 'package:oj_helper/utils/favorite_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoriteUtils', () {
    test('JSON 格式存储含逗号的比赛名不丢数据、可完整还原', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const name = 'Codeforces Round 1, sponsored by X';
      final encoded = FavoriteUtils.encodeContest(
          name, 100, 7200, 'Codeforces', 'https://codeforces.com/contests');
      await prefs.setString(name, encoded);
      await prefs.setString('favourite_contests', '["$name"]');

      expect(FavoriteUtils.getFavoriteNames(prefs), [name]);

      final contest = FavoriteUtils.parseStoredContest(encoded);
      expect(contest, isNotNull);
      expect(contest!.name, name);
      expect(contest.startTimeSeconds, 100);
      expect(contest.durationSeconds, 7200);
      expect(contest.platform, 'Codeforces');
      expect(contest.link, 'https://codeforces.com/contests');
    });

    test('兼容旧逗号分隔格式', () {
      final contest = FavoriteUtils.parseStoredContest('旧比赛,100,7200,牛客,https://x');
      expect(contest, isNotNull);
      expect(contest!.name, '旧比赛');
      expect(contest.startTimeSeconds, 100);
      expect(contest.link, 'https://x');
    });

    test('旧格式字段损坏时不崩溃，返回 null', () {
      // 旧格式下名字含逗号会导致字段错位，必须安全跳过而不是崩溃
      expect(FavoriteUtils.parseStoredContest('名字,含逗号,坏数据'), isNull);
      expect(FavoriteUtils.parseStoredContest('只有名字'), isNull);
    });

    test('旧逗号分隔的收藏名列表兼容读取', () async {
      SharedPreferences.setMockInitialValues({'favourite_contests': 'A,B,C'});
      final prefs = await SharedPreferences.getInstance();
      expect(FavoriteUtils.getFavoriteNames(prefs), ['A', 'B', 'C']);
    });

    test('空列表/空数据安全', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(FavoriteUtils.getFavoriteNames(prefs), isEmpty);
      expect(FavoriteUtils.parseStoredContest(''), isNull);
    });
  });
}
