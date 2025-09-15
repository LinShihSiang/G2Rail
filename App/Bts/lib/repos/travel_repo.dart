import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

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

class TravelRepo {
  final String baseUrl;
  final String apiKey;
  final String secret;
  final http.Client httpClient;

  TravelRepo({
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

    // Debug logging for authorization
    developer.log('[TravelRepo] Authorization Debug:', name: 'G2Rail');
    developer.log('  Params: $params', name: 'G2Rail');
    developer.log('  Sorted keys: $sortedKeys', name: 'G2Rail');
    developer.log('  Hash string: $hashString', name: 'G2Rail');
    developer.log('  Authorization hash: $authorization', name: 'G2Rail');

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

    final headers = getAuthorizationHeaders(criteria.toMap());
    developer.log('  Headers: $headers', name: 'G2Rail');

    final solutionResponse = await httpClient.get(
      Uri.parse(solutionUrl),
      headers: headers,
    );

    // Debug logging for response
    developer.log('[TravelRepo] API Response:', name: 'G2Rail');
    developer.log('  Status Code: ${solutionResponse.statusCode}', name: 'G2Rail');
    developer.log('  Response Headers: ${solutionResponse.headers}', name: 'G2Rail');
    developer.log('  Response Body: ${solutionResponse.body}', name: 'G2Rail');

    if (solutionResponse.statusCode != 200) {
      developer.log('[TravelRepo] ERROR: Non-200 status code', name: 'G2Rail');
      throw Exception('error getting solutions - Status: ${solutionResponse.statusCode}, Body: ${solutionResponse.body}');
    }

    final solutionsJson = jsonDecode(solutionResponse.body);

    // Debug logging for parsed response
    developer.log('[TravelRepo] Parsed Response:', name: 'G2Rail');
    developer.log('  Full JSON: $solutionsJson', name: 'G2Rail');

    if (solutionsJson is Map) {
      developer.log('  Keys in response: ${solutionsJson.keys.toList()}', name: 'G2Rail');

      if (solutionsJson.containsKey('async')) {
        final solutions = solutionsJson['async'];
        developer.log('  async found: ${solutions is List ? solutions.length : 'Not a list'}', name: 'G2Rail');
        if (solutions is List && solutions.isNotEmpty) {
          developer.log('  First solution: ${solutions.first}', name: 'G2Rail');
        }
      } else {
        developer.log('  WARNING: No "async" key found in response', name: 'G2Rail');
      }

      if (solutionsJson.containsKey('message')) {
        developer.log('  API Message: ${solutionsJson['message']}', name: 'G2Rail');
      }

      if (solutionsJson.containsKey('error')) {
        developer.log('  API Error: ${solutionsJson['error']}', name: 'G2Rail');
      }
    }

    return getAsyncResult(solutionsJson['async_key']?.toString() ?? '');
  }

  Future<dynamic> getAsyncResult(String asyncKey) async {
    final asyncResultURl = '$baseUrl/api/v2/async_results/$asyncKey';

    // Debug logging for async request
    developer.log('[TravelRepo] Getting Async Result:', name: 'G2Rail');
    developer.log('  URL: $asyncResultURl', name: 'G2Rail');
    developer.log('  Async Key: $asyncKey', name: 'G2Rail');

    final headers = getAuthorizationHeaders({"async_key": asyncKey});
    final asyncResult = await httpClient.get(
      Uri.parse(asyncResultURl),
      headers: headers,
    );

    // Debug logging for async response
    developer.log('[TravelRepo] Async Response:', name: 'G2Rail');
    developer.log('  Status Code: ${asyncResult.statusCode}', name: 'G2Rail');
    developer.log('  Response Headers: ${asyncResult.headers}', name: 'G2Rail');
    developer.log('  Response Body: ${utf8.decode(asyncResult.bodyBytes)}', name: 'G2Rail');

    if (asyncResult.statusCode != 200) {
      developer.log('[TravelRepo] ERROR: Async result failed', name: 'G2Rail');
      throw Exception('error getting async result - Status: ${asyncResult.statusCode}, Body: ${utf8.decode(asyncResult.bodyBytes)}');
    }

    final decodedResponse = jsonDecode(utf8.decode(asyncResult.bodyBytes));
    developer.log('  Decoded Response: $decodedResponse', name: 'G2Rail');

    return decodedResponse;
  }

  /// Complete async search workflow: call online_solutions, get async key, poll for results
  Future<dynamic> searchTrainsAsync(
    String from,
    String to,
    String date,
    String time,
    int adult,
    int child,
    int junior,
    int senior,
    int infant, {
    int maxAttempts = 30,
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    developer.log('[TravelRepo] Starting async train search workflow', name: 'G2Rail');

    // Step 1: Call online_solutions to get async key
    final solutionsResponse = await getSolutions(
      from, to, date, time, adult, child, junior, senior, infant
    );

    // Extract async key from response
    String? asyncKey;
    if (solutionsResponse is Map) {
      asyncKey = solutionsResponse['async_key']?.toString();

      // Check if we got solutions immediately (synchronous response)
      if (solutionsResponse.containsKey('solutions') &&
          solutionsResponse['solutions'] is List &&
          (solutionsResponse['solutions'] as List).isNotEmpty) {
        developer.log('[TravelRepo] Got synchronous solutions, returning immediately', name: 'G2Rail');
        return solutionsResponse;
      }
    }

    if (asyncKey == null || asyncKey.isEmpty) {
      developer.log('[TravelRepo] ERROR: No async key received', name: 'G2Rail');
      throw Exception('No async key received from online_solutions API');
    }

    developer.log('[TravelRepo] Received async key: $asyncKey', name: 'G2Rail');
    developer.log('[TravelRepo] Starting polling with max $maxAttempts attempts every ${pollInterval.inSeconds}s', name: 'G2Rail');

    // Step 2: Poll async results
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      developer.log('[TravelRepo] Polling attempt $attempt/$maxAttempts', name: 'G2Rail');

      try {
        final asyncResponse = await getAsyncResult(asyncKey);

        if (asyncResponse is Map) {
          // Check if results are ready
          final data = asyncResponse['data'];
          if (data is Map) {
            final status = data['status']?.toString();
            final solutions = data['solutions'];

            developer.log('[TravelRepo] Async response status: $status', name: 'G2Rail');

            if (status == 'completed' || status == 'success') {
              if (solutions is List && solutions.isNotEmpty) {
                developer.log('[TravelRepo] SUCCESS: Got ${solutions.length} solutions', name: 'G2Rail');
                return data; // Return the actual solutions data
              } else {
                developer.log('[TravelRepo] Completed but no solutions found', name: 'G2Rail');
                return data; // Return anyway, let UI handle empty results
              }
            } else if (status == 'failed' || status == 'error') {
              developer.log('[TravelRepo] ERROR: Async search failed with status: $status', name: 'G2Rail');
              throw Exception('Async search failed: $status');
            } else if (status == 'processing' || status == 'pending') {
              developer.log('[TravelRepo] Still processing, waiting...', name: 'G2Rail');
            } else {
              developer.log('[TravelRepo] Unknown status: $status, continuing to poll...', name: 'G2Rail');
            }
          }
        }

        // Wait before next attempt (except on last attempt)
        if (attempt < maxAttempts) {
          await Future.delayed(pollInterval);
        }

      } catch (e) {
        developer.log('[TravelRepo] Error during polling attempt $attempt: $e', name: 'G2Rail');
        if (attempt == maxAttempts) {
          rethrow; // Re-throw on final attempt
        }
        // Wait before retry
        await Future.delayed(pollInterval);
      }
    }

    developer.log('[TravelRepo] ERROR: Polling timeout after $maxAttempts attempts', name: 'G2Rail');
    throw Exception('Timeout waiting for search results after $maxAttempts attempts');
  }
}