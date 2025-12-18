import 'package:cli_flutter/models/iptv_channel.dart';
import 'package:cli_flutter/services/channel_request.dart';
import 'package:get/get.dart';

class PlayPageController extends GetxController {
  int page = 1;
  int pageSize = 10;
  RxList<IPTVChannel> channelsGroup = <IPTVChannel>[].obs;
  late ChannelRequestService _channelService;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  RxBool isSwitching = false.obs;

  Rx<IPTVChannel?> currentChannel = Rx<IPTVChannel?>(null);

  PlayPageController();

  @override
  void onInit() {
    super.onInit();
    _channelService = ChannelRequestService();
  }

  /// 加载频道列表
  /// isRefresh 是否刷新
  Future<void> loadChannels({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        page = 1;
      } else {
        if (hasMore.value != true || isLoading.value == true) {
          return;
        }
      }
      isLoading.value = true;
      List<IPTVChannel> channels = await _channelService.getChannels(
        page: page,
        pageSize: pageSize, // 获取更多频道以供选择
      );
      page++;
      if (channels.isNotEmpty) {
        //没到最后一页
        if (isRefresh) {
          channelsGroup.clear();
          channelsGroup.value = channels;
        } else {
          channelsGroup.addAll(channels);
        }
      } else {
        //已到最后一页
        hasMore.value = false;
      }
    } catch (e) {
      // 处理错误
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    channelsGroup.clear();
    super.onClose();
  }
}
