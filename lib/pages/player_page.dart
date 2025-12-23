import 'package:better_player_plus/better_player_plus.dart';
import 'package:cli_flutter/controller/play_page_controller.dart';
import 'package:cli_flutter/pages/channel_list_page.dart';
import 'package:cli_flutter/services/channel_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cli_flutter/models/iptv_channel.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController _controller;
  late PlayPageController _playPageController;

  IPTVChannel? get _currentChannel {
    return _playPageController.currentChannel.value;
  }

  set _currentChannel(newValue) {
    _playPageController.currentChannel.value = newValue;
  }

  @override
  void initState() {
    super.initState();
    _playPageController = Get.put<PlayPageController>(PlayPageController());

    // 设置默认横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _loadChannels();

    // 监听遥控器按键事件
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    // 恢复屏幕方向设置
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _controller.dispose();
    Get.delete<PlayPageController>();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    await _playPageController.loadChannels(isRefresh: true);
    if (_currentChannel == null &&
        _playPageController.channelsGroup.isNotEmpty) {
      if (mounted) {
        setState(() {
          _currentChannel = _playPageController.channelsGroup[0];
        });
      }
      if (_currentChannel != null) {
        _initializePlayer(_currentChannel!);
      }
    }
  }

  void _initializePlayer(IPTVChannel channel) {
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      channel.streamUrl,
      liveStream: true,
    );
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        autoDetectFullscreenDeviceOrientation: true,
        // 使用BetterPlayer的overlay机制来添加覆盖层
        fit: BoxFit.fitHeight,
        overlay: _buildPlayerOverlay(),
        eventListener: (BetterPlayerEvent event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play) {
            // 视频开始播放时的处理
          } else if (event.betterPlayerEventType ==
              BetterPlayerEventType.pause) {
            // 视频暂停时的处理
          }
        },
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          // 隐藏控制栏
          showControlsOnInitialize: false,
          // 初始化时不显示控制栏
          enableSkips: false,
          // 禁用跳过按钮
          enableOverflowMenu: false,
          // 禁用溢出菜单
          enablePlayPause: false,
          // 禁用播放/暂停按钮
          enableProgressText: false,
          // 禁用进度文本
          enableRetry: false, // 禁用重试按钮
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  // 构建播放器覆盖层
  Widget _buildPlayerOverlay() {
    return Stack(
      children: [
        // 频道信息显示
        // Positioned(
        //   top: 50,
        //   left: 20,
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: Colors.black54,
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Text(
        //       _currentChannel?.name ?? '',
        //       style: const TextStyle(color: Colors.white, fontSize: 16),
        //     ),
        //   ),
        // ),
        // 点击区域覆盖在整个播放器上
        Positioned.fill(
          child: GestureDetector(
            onTap: _toggleChannelList,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
    return Obx(() {
      return Stack(
        children: [
          // 频道信息显示
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentChannel?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // 点击区域覆盖在整个播放器上
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChannelList,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    });
  }

  bool _handleKeyEvent(KeyEvent event) {
    // 处理遥控器确认键事件
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.gameButton1) {
        _toggleChannelList();
        return true;
      }

      // 处理遥控器方向键
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // 向上键处理
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // 向下键处理
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // 向左键处理
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // 向右键处理
      }
    }
    return false;
  }

  void _toggleChannelList() {
    _showChannelSelector();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Obx(() {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _currentChannel == null
                  ? const Center(child: Text('没有可用的频道'))
                  : BetterPlayer(controller: _controller),
              _playPageController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : SizedBox(),
              _playPageController.isSwitching.value == true
                  ? const Center(
                      child: SpinKitRotatingCircle(
                        color: Colors.white,
                        size: 50.0,
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _showChannelSelector() async {
    ChannelListPage.show(
      _playPageController,
      _selectChannel,
      _currentChannel ?? _playPageController.channelsGroup.first,
      _selectChildChannel,
    );
  }

  void _selectChannel(IPTVChannel channel) async {
    //记录当前的_currentChannel
    _playPageController.isSwitching.value = true;
    IPTVChannel? recordChannel = _currentChannel;
    try {
      _currentChannel = channel;
      var dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        channel.streamUrl,
        liveStream: true,
      );
      await _controller.setupDataSource(dataSource);
    } catch (e) {
      if (_currentChannel != null) {
        Fluttertoast.showToast(
          msg: "${_currentChannel?.name}频道播放失败",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        _currentChannel = recordChannel;
        var dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          _currentChannel!.streamUrl,
          liveStream: true,
        );
        await _controller.setupDataSource(dataSource);
      }
    }
    _playPageController.isSwitching.value = false;
  }

  Future<void> _selectChildChannel(
    IPTVChannel channel,
    IPTVChannelVariant childItem,
  ) async {
    //记录当前的_currentChannel
    _playPageController.isSwitching.value = true;
    IPTVChannel? recordChannel = _currentChannel;
    try {
      _currentChannel = channel;
      childItem.selectState = true;
      var dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        childItem.streamUrl,
        liveStream: true,
      );
      await _controller.setupDataSource(dataSource);
      //播放成功，进行channel缓存
      ChannelCacheManager.shareInstance.cacheChannel(channel);
    } catch (e) {
      if (_currentChannel != null) {
        childItem.selectState = false;
        Fluttertoast.showToast(
          msg: "${_currentChannel?.name}频道播放失败",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        _currentChannel = recordChannel;
        var dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          getNeedPlayStream(_currentChannel!),
          liveStream: true,
        );
        await _controller.setupDataSource(dataSource);
      }
    }
    _playPageController.isSwitching.value = false;
  }

  ///获取当前选择饿的子频道
  IPTVChannelVariant? getSelectChildChannelItem(IPTVChannel? channel) {
    return channel?.variants.firstWhereOrNull((e) {
      return e.selectState == true;
    });
  }

  ///获取当前需要播放的url
  String getNeedPlayStream(IPTVChannel channel) {
    IPTVChannelVariant? childItem = getSelectChildChannelItem(channel);
    if (childItem != null) {
      return childItem.streamUrl;
    }
    return channel.streamUrl;
  }
}
