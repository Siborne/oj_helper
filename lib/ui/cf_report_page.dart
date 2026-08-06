import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/report_services.dart';

class CfReportPage extends StatefulWidget {
  @override
  State<CfReportPage> createState() {
    return _CfReportPageState();
  }
}

class _CfReportPageState extends State<CfReportPage> {
  List<PieChartSectionData> dataList = [];
  ReportServices report = ReportServices();
  final TextEditingController _controller = TextEditingController();

  static const List<Color> _pieColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.redAccent,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
  ];

  void _fetchData() async {
    String username = _controller.text.trim();
    if (username.isEmpty) return;
    List<Map<String, dynamic>> data;
    try {
      data = await report.fetchCodeforcesData(username);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('查询失败，请检查用户名或网络')),
        );
      }
      return;
    }
    // 统计每题涉及的所有 tag（同一题可含多个 tag），按数量生成饼图
    Map<String, int> tag = {};
    for (var i in data) {
      for (var j in (i['tags'] as List? ?? [])) {
        final key = j.toString();
        tag[key] = (tag[key] ?? 0) + 1;
      }
    }
    // 按数量降序排列，保证饼图从大到小展示，颜色循环分配
    final sorted = tag.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      dataList = [];
      var colorIndex = 0;
      for (final e in sorted) {
        dataList.add(PieChartSectionData(
          value: e.value.toDouble(),
          title: e.key,
          color: _pieColors[colorIndex % _pieColors.length],
          titleStyle: const TextStyle(fontSize: 12, color: Colors.black),
        ));
        colorIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('cf分析'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '请输入cf用户名',
                      border: OutlineInputBorder(),
                    ),
                    onEditingComplete: _fetchData,
                  ),
                ),
                const SizedBox(width: 10), // 添加间距
                ElevatedButton(
                  onPressed: _fetchData,
                  child: const Text('查询'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: dataList,
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放控制器
    super.dispose();
  }
}
