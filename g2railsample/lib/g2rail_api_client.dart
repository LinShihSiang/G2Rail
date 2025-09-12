import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class SearchCriteria {
  final String from;
  final String to;
  final String date;
  final String time;
  final int adult;
  final int child;
  final int junior;
  final int senior;
  final int infant;

  SearchCriteria(
    this.from,
    this.to,
    this.date,
    this.time,
    this.adult,
    this.child,
    this.junior,
    this.senior,
    this.infant,
  );

  String toQuery() {
    return "from=$from&to=$to&date=$date&time=$time&adult=$adult&child=$child&junior=$junior&senior=$senior&infant=$infant";
  }

  Map<String, dynamic> toMap() {
    return {
      "from": from,
      "to": to,
      "date": date,
      "time": time,
      "adult": adult,
      "child": child,
      "junior": junior,
      "senior": senior,
      "infant": infant,
    };
  }
}

class GrailApiClient {
  final baseUrl;
  final apiKey; //TODO ASK PM to get apiKey and secret
  final secret;
  final http.Client httpClient;

  GrailApiClient({
    required this.httpClient,
    required this.baseUrl,
    required this.apiKey,
    required this.secret,
  });

  Map<String, String> getAuthorizationHeaders(Map<String, dynamic> params) {
    var timestamp = DateTime.now();
    params['t'] = (timestamp.millisecondsSinceEpoch ~/ 1000).toString();
    params['api_key'] = apiKey;

    var sortedKeys = params.keys.toList()..sort((a, b) => a.compareTo(b));
    StringBuffer buffer = StringBuffer("");
    for (var key in sortedKeys) {
      if (params[key] is List || params[key] is Map) continue;
      buffer.write('$key=${params[key].toString()}');
    }
    buffer.write(secret);

    String hashString = buffer.toString();
    String authorization = md5.convert(utf8.encode(hashString)).toString();

    return {
      "From": apiKey,
      "Content-Type": 'application/json',
      "Authorization": authorization,
      "Date": HttpDate.format(timestamp),
      "Api-Locale": "zh-TW",
    };
  }

  Future<dynamic> getSolutions(
    String from,
    String to,
    String date,
    String time,
    int adult,
    int child,
    int junior,
    int senior,
    int infant,
  ) async {
    final criteria = SearchCriteria(
      from,
      to,
      date,
      time,
      adult,
      child,
      junior,
      senior,
      infant,
    );
    final solutionUrl =
        '$baseUrl/api/v2/online_solutions/?${criteria.toQuery()}';

    final solutionResponse = await httpClient.get(
      Uri.parse(solutionUrl),
      headers: getAuthorizationHeaders(criteria.toMap()),
    );

    if (solutionResponse.statusCode != 200) {
      throw Exception('error getting solutions');
    }

    final solutionsJson = jsonDecode(solutionResponse.body);
    print(solutionResponse.body);
    return solutionsJson;
  }

  Future<dynamic> getAsyncResult(String asyncKey) async {
    final asyncResultURl = '$baseUrl/api/v2/async_results/$asyncKey';
    final asyncResult = await httpClient.get(
      Uri.parse(asyncResultURl),
      headers: getAuthorizationHeaders({"async_key": asyncKey}),
    );
    return {"data": jsonDecode(utf8.decode(asyncResult.bodyBytes))};
  }
}
