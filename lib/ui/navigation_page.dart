import 'package:flutter/material.dart';
import 'package:oj_helper/ui/favorites_page.dart';
import 'package:oj_helper/ui/service_page.dart';
import 'package:oj_helper/ui/setting_page.dart';

import 'recent_contest_page.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  //当前选中项
  int _selectedIndex = 0;
  // 收藏页 key：IndexedStack 下页面常驻，切到收藏 tab 时需主动刷新
  final GlobalKey<FavoritesPageState> _favoritesKey =
      GlobalKey<FavoritesPageState>();
  //页面列表（在 initState 中初始化，字段初始化器不能引用 this）
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecentContestPage(),
      FavoritesPage(key: _favoritesKey),
      ServicePage(),
      SettingPage(),
    ];
  }

  // 切换页面
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // 切到收藏页时刷新收藏列表（近期比赛页可能刚收藏了新的比赛）
    if (index == 1) {
      _favoritesKey.currentState?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //动画样式
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHight = constraints.maxHeight;
            if (screenWidth / screenHight > 1.1) {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onTabSelected,
                    leading: SizedBox(height: 10),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.event_note),
                        label: Text('比赛'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.star),
                        label: Text('收藏'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.list),
                        label: Text('功能'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Text('设置'),
                      ),
                    ],
                  ),
                  // 页面内容（IndexedStack 保持各页面状态，切换不重建）
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  // 页面内容（IndexedStack 保持各页面状态，切换不重建）
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                  // 底部导航栏
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                          icon: Icon(Icons.event_note), label: '比赛'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.star), label: '收藏'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.list), label: '功能'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.settings), label: '设置'),
                    ],
                    selectedIconTheme: IconThemeData(
                      color: Colors.blue,
                      size: 30,
                    ),
                    type: BottomNavigationBarType.fixed,
                    unselectedItemColor: Colors.grey,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    currentIndex: _selectedIndex,
                    selectedLabelStyle: TextStyle(color: Colors.blue),
                    // 点击事件
                    onTap: _onTabSelected,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
