import 'package:cli_flutter/controller/play_page_controller.dart';
import 'package:cli_flutter/models/iptv_channel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';

class ChannelListPage extends StatefulWidget {
  final PlayPageController playPageController;
  final void Function(IPTVChannel) selectChannelFunc;
  final IPTVChannel currentChannel;

  const ChannelListPage({
    super.key,
    required this.playPageController,
    required this.selectChannelFunc,
    required this.currentChannel,
  });

  @override
  State createState() => _ChannelListPageState();

  static Future<void> show(
    PlayPageController playPageController,
    void Function(IPTVChannel) selectChannelFunc,
    IPTVChannel currentChannel,
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
          child: ChannelListPage(
            playPageController: playPageController,
            selectChannelFunc: selectChannelFunc,
            currentChannel: currentChannel,
          ),
        );
      },
    );
  }
}

class _ChannelListPageState extends State<ChannelListPage> {
  double get cellHeight {
    return 60.0;
  }

  PlayPageController get playPageController {
    return widget.playPageController;
  }

  IPTVChannel get currentChannel {
    return widget.currentChannel;
  }

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (playPageController.channelsGroup.isNotEmpty == true) {
        int index = playPageController.channelsGroup.indexWhere((e) {
          return e.streamUrl == currentChannel.streamUrl;
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
        padding: EdgeInsets.only(top: 20),
        child: Container(
          width: MediaQuery.of(context).size.width / 2.0,
          margin: EdgeInsets.only(left: 40),
          child: EasyRefresh(
            onRefresh: refreshData,
            onLoad: loadMoreData,
            header: CupertinoHeader(foregroundColor: Colors.blue),
            footer: CupertinoFooter(foregroundColor: Colors.blue),
            child: Obx(() {
              return ListView.builder(
                itemCount: playPageController.channelsGroup.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  final channel = playPageController.channelsGroup[index];
                  return SizedBox(
                    height: cellHeight,
                    child: ListTile(
                      title: Text(
                        channel.name,
                        style: TextStyle(
                          color: currentChannel.name == channel.name
                              ? Colors.blue
                              : Colors.white,
                        ),
                      ),
                      subtitle: channel.groupTitle != null
                          ? Text(
                              channel.groupTitle ?? '',
                              style: const TextStyle(color: Colors.grey),
                            )
                          : null,
                      onTap: () {
                        widget.selectChannelFunc(channel);
                        Get.back();
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> refreshData() async {
    await playPageController.loadChannels(isRefresh: true);
  }

  Future<void> loadMoreData() async {
    await playPageController.loadChannels(isRefresh: false);
  }
}
