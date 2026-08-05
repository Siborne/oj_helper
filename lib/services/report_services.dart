import 'package:dio/dio.dart';

class ReportServices {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));
  Future<List<Map<String, dynamic>>> fetchCodeforcesData(String handle) async {
    // CF API 对 user.status 的 count 有上限（约 1e4 条），过大会被拒绝
    final codeforcesUrl =
        'https://codeforces.com/api/user.status?handle=$handle&from=1&count=10000';
    final response = await dio.get(codeforcesUrl);
    if (response.statusCode != 200 || response.data['status'] != 'OK') {
      throw Exception('Failed to fetch data: ${response.data['comment']}');
    }
    final Set<String> st = {};
    final List<Map<String, dynamic>> ans = [];
    for (var i in response.data['result']) {
      final problem = i['problem'];
      if (problem == null || i['verdict'] != 'OK') {
        continue;
      }
      final tmp =
          '${problem['contestId']}${problem['index']}${problem['name']}';
      if (st.add(tmp)) {
        ans.add({
          'rating': problem['rating'] ?? 0,
          'tags': problem['tags'] ?? [],
        });
      }
    }
    return ans;
  }
}
