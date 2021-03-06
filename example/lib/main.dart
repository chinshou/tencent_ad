import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_ad/tencent_ad.dart';

void main() {
  runApp(TencentADApp());
}

class TencentADApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TencentADAppState();
}

class _TencentADAppState extends State<TencentADApp> {
  @override
  void initState() {
    TencentADPlugin.config(appID: '1109716769').then(
      (_) => SplashAD(
          posID: configID['splashID'],
          callBack: (event, args) {
            switch (event) {
              case SplashADEvent.onNoAD:
              case SplashADEvent.onADDismissed:
                SystemChrome.setEnabledSystemUIOverlays([
                  SystemUiOverlay.top,
                  SystemUiOverlay.bottom,
                ]);
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                );
                break;
              default:
            }
          }).showAD(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          '腾讯广告',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.values[0],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1.0, 80.0, 0.0, 32.0),
                items: [
                  PopupMenuItem(
                    child: Text('退出'),
                    value: 0,
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 0:
                    SystemNavigator.pop();
                    exit(0);
                    break;
                  default:
                }
              });
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          ItemIcon(
            icon: 'reward_video',
            name: '激励视频广告',
            onTap: () {},
          ),
          ItemIcon(
            icon: 'interstital_ad',
            name: '插屏广告',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => IntersADWidget(
                  configID['intersID'],
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'banner_ad',
            name: '横幅广告',
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                enableDrag: true,
                builder: (context) {
                  return _buildBanner();
                },
              );
            },
          ),
          ItemIcon(
            icon: 'origin_ad',
            name: '原生广告',
            onTap: () {},
          ),
          ItemIcon(
            icon: 'splash_ad',
            name: '闪屏广告',
            onTap: () {
              SplashAD(
                  posID: configID['splashID'],
                  callBack: (event, args) {
                    switch (event) {
                      case SplashADEvent.onNoAD:
                      case SplashADEvent.onADDismissed:
                        SystemChrome.setEnabledSystemUIOverlays([
                          SystemUiOverlay.top,
                          SystemUiOverlay.bottom,
                        ]);
                        SystemChrome.setSystemUIOverlayStyle(
                          SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent),
                        );
                        break;
                      default:
                    }
                  }).showAD();
            },
          ),
        ],
      ),
    );
  }

  // 横幅广告示例
  Widget _buildBanner() {
    final _adKey = GlobalKey<BannerADState>();
    final size = MediaQuery.of(context).size;
    return BannerAD(
      posID: configID['bannerID'],
      key: _adKey,
      callBack: (event, args) {
        switch (event) {
          case BannerEvent.onADClosed:
          case BannerEvent.onADCloseOverlay:
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1.0, size.height * .82, 0.0, 0.0),
              items: [
                PopupMenuItem(
                  child: Text('刷新'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('关闭'),
                  value: 1,
                ),
              ],
            ).then((value) {
              switch (value) {
                case 0:
                  _adKey.currentState.loadAD();
                  break;
                case 1:
                  _adKey.currentState.closeAD();
                  Navigator.pop(context);
                  break;
                default:
              }
            });
            break;
          default:
        }
      },
      refresh: true,
    );
  }
}

class ItemIcon extends StatelessWidget {
  const ItemIcon({
    @required this.icon,
    @required this.name,
    @required this.onTap,
  });

  final String icon;
  final String name;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/svg/$icon.svg',
              width: 88.0,
              height: 88.0,
              fit: BoxFit.cover,
            ),
          ),
          Text('$name'),
        ],
      ),
    );
  }
}

Map<String, String> get configID {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return {
        'appID': '1109716769',
        'splashID': '7020785136977336',
        'bannerID': '9040882216019714',
        'intersID': '2041008945668154',
        'rewardID': '6021002701726334',
        'nativeID': '8041808915486340',
      };
      break;
    case TargetPlatform.iOS:
      return {
        'appID': '',
        'splashID': '',
        'bannerID': '',
        'intersID': '',
        'rewardID': '',
        'nativeID': '',
      };
      break;
    default:
      return {'': ''};
  }
}

class IntersADWidget extends StatefulWidget {
  final String posID;

  IntersADWidget(this.posID);

  @override
  State<StatefulWidget> createState() => IntersADWidgetState();
}

class IntersADWidgetState extends State<IntersADWidget> {
  IntersAD intersAD;

  @override
  void initState() {
    super.initState();
    intersAD = IntersAD(posID: widget.posID, adEventCallback: _adEventCallback);
    intersAD.loadAD();
  }

  @override
  Widget build(BuildContext context) => Container();

  void _adEventCallback(IntersADEvent event, Map params) {
    switch (event) {
      case IntersADEvent.onADReceived:
        intersAD.showAD();
        break;
      case IntersADEvent.onADClosed:
        Navigator.of(context).pop();
        break;
      default:
    }
  }
}
