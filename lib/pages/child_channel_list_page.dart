import 'package:cli_flutter/controller/play_page_controller.dart';
import 'package:cli_flutter/services/channel_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/iptv_channel.dart';

class ChildChannelListPage extends StatefulWidget {
  final PlayPageController playPageController;
  final void Function(IPTVChannelVariant) selectChannelFunc;
  final IPTVChannel? clickChannel;

  const ChildChannelListPage({
    super.key,
    required this.playPageController,
    required this.selectChannelFunc,
    required this.clickChannel,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChildChannelListPageState();
  }

  static Future<void> show(
    PlayPageController playPageController,
    void Function(IPTVChannelVariant) selectChannelFunc,
    IPTVChannel? clickChannel,
  ) async {
    // 直接使用 Flutter 原生的 showModalBottomSheet
    await showModalBottomSheet(
      // context 从 Get.context! 获取，确保在 GetMaterialApp 下可用
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      // 关键：使用 constraints 强制宽度
      constraints: BoxConstraints(
        maxWidth: Get.width, // 设置最大宽度为屏幕宽度
      ),
      // 去除默认的顶部圆角
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        // 在 builder 中返回你的页面实例
        return SafeArea(
          child: ChildChannelListPage(
            playPageController: playPageController,
            selectChannelFunc: selectChannelFunc,
            clickChannel: clickChannel,
          ),
        );
      },
    );
  }
}

class _ChildChannelListPageState extends State<ChildChannelListPage> {
  double get cellHeight {
    return 60.0;
  }

  PlayPageController get playPageController {
    return widget.playPageController;
  }

  IPTVChannelVariant? get currentChildChannel {
    ChannelCacheManager.shareInstance.getSelectCacheChild(currentChannel);
    return currentChannel?.variants.firstWhereOrNull((e) {
      return e.selectState == true;
    });
  }

  IPTVChannel? get currentChannel {
    return widget.clickChannel;
  }

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (currentChannel?.variants.isNotEmpty == true &&
          currentChildChannel != null) {
        int index = currentChannel!.variants.indexWhere((e) {
          return e.streamUrl == currentChildChannel!.streamUrl;
        });
        if (index != -1) {
          double offset = index * cellHeight;
          scrollController.animateTo(
            offset,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(top: 20, left: 40),
        child: ListView.builder(
          itemCount: currentChannel?.variants.length ?? 0,
          controller: scrollController,
          itemBuilder: (context, index) {
            final channel = currentChannel!.variants[index];
            return _buildChannelItem(channel, index);
          },
        ),
      ),
    );
  }

  Widget _buildChannelItem(IPTVChannelVariant channel, int index) {
    return SizedBox(
      height: cellHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              widget.selectChannelFunc(channel);
              Get.back();
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${channel.name ?? ''}    频道${index + 1}",
                  style: TextStyle(
                    color:
                        currentChildChannel?.name == channel.name &&
                            currentChildChannel?.streamUrl == channel.streamUrl
                        ? Colors.blue
                        : Colors.white,
                  ),
                ),
                Text(
                  channel.groupTitle ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
