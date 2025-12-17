import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cli_flutter/models/iptv_channel.dart';

class ChannelRequestService {
  static const String baseUrl = 'http://192.168.31.104:8000';
  late Dio _dio;

  ChannelRequestService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// 获取频道列表
  ///
  /// 参数:
  /// - page: 页码，默认为1
  /// - pageSize: 每页数量，默认为2
  ///
  /// 返回:
  // ignore: unintended_html_in_doc_comment
  /// - Future<List<IPTVChannel>>: 频道列表
  Future<List<IPTVChannel>> getChannels({
    int page = 1,
    int pageSize = 2,
  }) async {
    try {
      final response = await _dio.get(
        '/channels',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200) {
        List<IPTVChannel> channels = [];
        final pagination = response.data['pagination'];
        final total = pagination['total_pages'] ?? 0;
        if (total >= page) {
          final data = response.data['data'] ?? response.data;
          // 解析频道数据
          if (data is List) {
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                channels.add(IPTVChannel.fromJson(item));
              }
            }
          }
        }
        return channels;
      } else {
        throw Exception('Failed to load channels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取频道列表时发生未知错误: $e');
    }
  }

  /// 获取频道总数
  Future<int> getTotalChannels() async {
    try {
      final response = await _dio.get('/channels/count');

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      } else {
        throw Exception('Failed to get channel count: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('获取频道总数失败: ${e.message}');
    }
  }
}
