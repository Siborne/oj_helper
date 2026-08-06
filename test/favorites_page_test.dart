import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oj_helper/ui/favorites_page.dart';
import 'package:oj_helper/utils/favorite_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FavoritesPage.reload 能刷新出新收藏的比赛（IndexedStack 常驻场景）',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: FavoritesPage()));
    await tester.pump();

    // 初始无收藏，页面不显示任何比赛
    expect(find.text('测试比赛A'), findsNothing);

    // 模拟在"近期比赛"页收藏了比赛（写入 SharedPreferences）
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '测试比赛A',
        FavoriteUtils.encodeContest(
            '测试比赛A', 100, 7200, '牛客', 'https://ac.nowcoder.com'));
    await prefs.setString('favourite_contests', '["测试比赛A"]');

    // 切到收藏页时导航会调用 reload()
    final state = tester.state<FavoritesPageState>(find.byType(FavoritesPage));
    await state.reload();
    await tester.pump();

    // 新收藏的比赛应显示出来
    expect(find.text('测试比赛A'), findsOneWidget);
  });

  testWidgets('FavoritesPage.reload 多次调用不重复添加', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: FavoritesPage()));
    await tester.pump();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '测试比赛B', FavoriteUtils.encodeContest('测试比赛B', 200, 3600, 'Codeforces', null));
    await prefs.setString('favourite_contests', '["测试比赛B"]');

    final state = tester.state<FavoritesPageState>(find.byType(FavoritesPage));
    await state.reload();
    await tester.pump();
    await state.reload();
    await tester.pump();

    expect(find.text('测试比赛B'), findsOneWidget);
  });
}
