import 'package:dio/dio.dart';
import 'package:oj_helper/models/rating.dart' show Rating;
import 'package:html/parser.dart' show parse;

class RatingService {
  final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));

  ///获取codeforces的curRating,maxRating
  Future<Rating> getCodeforcesRating({name = ''}) async {
    final url =
        "https://codeforces.com/api/user.info?handles=$name&checkHistoricHandles=false";
    Response response = await dio.get(url);
    // 用户不存在时 API 返回 status=FAILED 且 result 为错误信息字符串；
    // 新账号可能没有 rating/maxRating（为 null），统一按 0 处理
    if (response.statusCode == 200 &&
        response.data['status'] == 'OK' &&
        (response.data['result'] as List).isNotEmpty) {
      final result = response.data['result'][0];
      final rating = (result['rating'] ?? 0) as int;
      final maxRating = (result['maxRating'] ?? 0) as int;
      return Rating(name: name, curRating: rating, maxRating: maxRating);
    } else {
      throw Exception("请求失败或用户不存在");
    }
  }

  ///获取Atcoder的curRating,maxRating
  Future<Rating> getAtCoderRating({name = ''}) async {
    final url = "https://atcoder.jp/users/$name";
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final document = parse(response.data);
      final tables = document.getElementsByClassName('dl-table mt-2');
      if (tables.isEmpty) {
        throw Exception('无法解析 AtCoder 页面（页面可能改版或用户不存在）');
      }
      final rating = tables[0].getElementsByTagName('tr');
      if (rating.length < 3) {
        throw Exception('无法解析 AtCoder rating 数据');
      }
      // 未参赛用户页面显示 '-'，int.parse 会抛 FormatException，先做防御
      int parseRating(int index) {
        final spans = rating[index].getElementsByTagName('span');
        final text = spans.isEmpty ? '-' : spans[0].text.trim();
        if (text.isEmpty || text == '-') {
          throw Exception('该用户暂无 rating');
        }
        return int.parse(text);
      }
      return Rating(
          name: name, curRating: parseRating(1), maxRating: parseRating(2));
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取力扣的curRating,(rating历史，todo)
  Future<List<Rating>> getLeetCodeRating({name = ''}) async {
    const url = 'https://leetcode.cn/graphql/noj-go/';
    final data = {
      "query": """
      query userContestRankingInfo(\$userSlug: String!) {
        userContestRanking(userSlug: \$userSlug) {
          rating
          globalRanking
          localRanking
          globalTotalParticipants
          localTotalParticipants
          topPercentage
        }
        userContestRankingHistory(userSlug: \$userSlug) {
          attended
          rating
          ranking
          contest{
            title
            startTime
          }
        }
      }
      """,
      "variables": {"userSlug": name},
      "operationName": "userContestRankingInfo"
    };
    Response response = await dio.post(url, data: data);
    if (response.statusCode == 200) {
      final ratingList = response.data['data']['userContestRankingHistory'];
      List<Rating> ratingHistory = [];
      int maxmRating = 0;
      for (var i in ratingList) {
        if (i['attended'] == false) continue;
        maxmRating =
            i['rating'] > maxmRating ? i['rating'].toInt() : maxmRating;
        ratingHistory.add(Rating(
            name: i['contest']['title'],
            curRating: i['rating'].toInt(),
            maxRating: maxmRating,
            ranking: i['ranking'],
            time: i['contest']['startTime']));
      }
      return ratingHistory;
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取洛谷的curRating和maxRating（近百场）
  Future<Rating> getLuoguRating({name = ''}) async {
    final baseUrl = 'https://www.luogu.com.cn/api/user/search?keyword=$name';
    Options options = Options(
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    int userId;
    Response response = await dio.get(baseUrl, options: options);
    if (response.statusCode != 200) {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
    final users = response.data?['users'];
    if (users is! List || users.isEmpty) {
      throw Exception('未找到该洛谷用户，请检查用户名');
    }
    userId = users[0]['uid'];
    final url =
        'https://www.luogu.com.cn/api/rating/elo?user=$userId&page=1&limit=100';
    response = await dio.get(url, options: options);
    if (response.statusCode == 200) {
      final records = response.data?['records']?['result'];
      if (records is! List || records.isEmpty) {
        throw Exception('该用户暂无 rating 记录');
      }
      final curRating = (records[0]['rating'] ?? 0) as int;
      int maxRating = 0;
      for (final i in records) {
        final r = (i['rating'] ?? 0) as int;
        maxRating = r > maxRating ? r : maxRating;
      }
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }

  ///获取牛客的curRating，maxRating
  Future<Rating> getNowcoderRating({name = ''}) async {
    final url = 'https://ac.nowcoder.com/acm/contest/rating-history?uid=$name';
    Response response = await dio.get(url);
    if (response.statusCode == 200) {
      final rateHistory = response.data?['data'];
      if (rateHistory is! List || rateHistory.isEmpty) {
        throw Exception('该用户暂无 rating 记录');
      }
      int toRating(dynamic v) => (v is num) ? v.toInt() : 0;
      final curRating = toRating(rateHistory.last['rating']);
      //获取rateHisory的最大rating
      int maxRating = 0;
      for (var i in rateHistory) {
        final r = toRating(i['rating']);
        maxRating = r > maxRating ? r : maxRating;
      }
      return Rating(name: name, curRating: curRating, maxRating: maxRating);
    } else {
      throw Exception("请求失败，状态码：${response.statusCode}");
    }
  }
}
