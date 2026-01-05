import 'dart:convert';

import 'package:cli_flutter/models/iptv_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';

class ChannelCacheManager {
  static ChannelCacheManager shareInstance = ChannelCacheManager._();
  late MMKV _mmkv;
  String MMKV_Channel_Key = "mmkv_channel_key";

  ChannelCacheManager._() {
    _mmkv = MMKV.defaultMMKV();
  }

  ///缓存选中的子频道
  bool cacheChannel(IPTVChannel? channel) {
    try {
      if (channel != null) {
        String channelName = channel.name;
        Map<String, dynamic> json = channel.toJson();
        if (channelName.isNotEmpty == true && json.isNotEmpty == true) {
          String key = '$MMKV_Channel_Key$channelName';
          //先判断是否存在，存在直接进行删除
          bool containKey = _mmkv.containsKey(key);
          if (containKey) {
            _mmkv.removeValue(key);
          }
          String cacheJsonStr = jsonEncode(json);
          return _mmkv.encodeString(key, cacheJsonStr);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return false;
  }

  ///删除缓存选中的子频道
  ///当选中主源的时候，清除该缓存
  void deleteCacheCahnnel(IPTVChannel? channel) {
    try {
      if (channel != null) {
        String channelName = channel.name;
        Map<String, dynamic> json = channel.toJson();
        if (channelName.isNotEmpty == true && json.isNotEmpty == true) {
          String key = '$MMKV_Channel_Key$channelName';
          //先判断是否存在，存在直接进行删除
          bool containKey = _mmkv.containsKey(key);
          if (containKey) {
            _mmkv.removeValue(key);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  ///获取当前选中缓存的子频道
  void getSelectCacheChild(IPTVChannel? channel) {
    try {
      if (channel != null) {
        String channelName = channel.name;
        String key = '$MMKV_Channel_Key$channelName';
        bool containKey = _mmkv.containsKey(key);
        if (containKey == true) {
          String? channelJsonStr = _mmkv.decodeString(key);
          if (channelJsonStr?.isNotEmpty == true) {
            Map<String, dynamic> json = Map<String, dynamic>.from(
              jsonDecode(channelJsonStr!) ?? '{}',
            );
            if (json.isNotEmpty == true) {
              IPTVChannel cacheChannel = IPTVChannel.fromJson(json);
              if (cacheChannel.variants.isNotEmpty == true &&
                  channel.variants.isNotEmpty == true) {
                IPTVChannelVariant? cacheChannelVariant = cacheChannel.variants
                    .firstWhereOrNull((e) {
                      return e.selectState == true;
                    });
                if (cacheChannelVariant != null) {
                  for (var e in channel.variants) {
                    if (e.name == cacheChannelVariant.name &&
                        e.streamUrl == cacheChannelVariant.streamUrl) {
                      e.selectState = true;
                      break;
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
