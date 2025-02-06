import 'dart:async';
import 'package:flutter_in_app_pip/pip_material_app.dart';
import 'package:you_tube/main/main_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localstorage/localstorage.dart';
import "package:scaled_app/scaled_app.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:you_tube/theme/color_theme.dart';
import 'package:adaptive_theme/adaptive_theme.dart';


Future<void> main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) {
      // screen width used in your UI design
      const double widthOfDesign = 375.0;
      if(deviceSize.width >= 600.0){//tablet
        return  widthOfDesign / deviceSize.width;
      }
      return  deviceSize.width / widthOfDesign;
    },
  );
  await initLocalStorage();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(adaptiveThemeMode: savedThemeMode,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.adaptiveThemeMode});
  final AdaptiveThemeMode? adaptiveThemeMode;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return _buildNarrowLayout(adaptiveThemeMode);
  }
  Widget _buildNarrowLayout(AdaptiveThemeMode? adaptiveThemeMode){

    return AdaptiveTheme(
      light: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
              dragHandleColor:  Color(0xff42C83C) // --> This will change the color of the drag handle
          ),
          colorScheme: lightColorScheme,
          useMaterial3: true,
          actionIconTheme: ActionIconThemeData(
            backButtonIconBuilder: (BuildContext context) => const Icon(Icons.chevron_left, size: 44,),
          )
      ),
      dark: ThemeData(
          bottomSheetTheme: BottomSheetThemeData(
              dragHandleColor:  Color(0xff42C83C) // --> This will change the color of the drag handle
          ),
          colorScheme: darkColorScheme,
          useMaterial3: true,
          actionIconTheme: ActionIconThemeData(
            backButtonIconBuilder: (BuildContext context) => const Icon(Icons.chevron_left, size: 44,),
          )
      ),
      initial: adaptiveThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => PiPMaterialApp(
        title: 'WeTube',
        theme: theme,
        darkTheme: darkTheme,
        // themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // 美国
          Locale('vi', 'VN'), // 越南
          Locale('pt', 'BR'), // 巴西
          Locale('pt', 'PT'),//葡萄牙
          Locale('zh', 'CN'),//中国
          Locale('fr', 'FR'),//法国
          Locale('es', 'CR'),//哥斯达黎加
          Locale('es', 'CO'),//哥伦比亚
          Locale('es', 'CL'),//智利
          Locale('fr', 'TD'),//乍得
          Locale('fr', 'CF'),//中非共和国
          Locale('en', 'KY'),//开曼群岛
          Locale('fr', 'CA'),//加拿大
          Locale('en', 'CA'),//加拿大
          Locale('fr', 'CM'),//喀麦隆
          Locale('km', 'KH'),//柬埔寨
          Locale('fr', 'BI'),//布隆迪
          Locale('bg', 'BG'),//保加利亚
          Locale('ms', 'BN'),//文莱
          Locale('es', 'BO'),//玻利维亚
          Locale('fr', 'BE'),//比利时
          Locale('be', 'BY'),//白俄罗斯
          Locale('bn', 'BD'),//孟加拉
          Locale('ar', 'BH'),//巴林
          Locale('en', 'BS'),//巴哈马
          Locale('az', 'AZ'),//阿塞拜疆
          Locale('de', 'AT'),//奥地利
          Locale('en', 'AU'),//澳大利亚
          Locale('hy', 'AM'),//亚美尼亚
          Locale('es', 'AR'),//阿根廷
          Locale('ca', 'AD'),//安道尔
          Locale('en', 'AS'),//美属萨摩亚
          Locale('ar', 'DZ'),//阿尔及利亚
          Locale('sq', 'AL'),//阿尔巴尼亚
          Locale('ps', 'AF'),//阿富汗
          Locale('id', 'ID'),//印度尼西亚
          Locale('ar', 'IQ'),//伊拉克
          Locale('is', 'IS'),//冰岛
          Locale('hu', 'HU'),//匈牙利
          Locale('es', 'HN'),//洪都拉斯
          Locale('en', 'GY'),//圭亚那
          Locale('da', 'GL'),//格陵兰
          Locale('fr', 'GN'),//几内亚
          Locale('es', 'GT'),//危地马拉
          Locale('ka', 'GE'),//格鲁吉亚
          Locale('fr', 'GA'),//加蓬
          Locale('fi', 'FI'),//芬兰
          Locale('fo', 'FO'),//法罗群岛
          Locale('ar', 'EG'),//埃及
          Locale('fr', 'DJ'),//吉布提
          Locale('da', 'DK'),//丹麦
          Locale('cs', 'CZ'),//捷克
          Locale('hr', 'HR'),//克罗地亚
          Locale('el', 'CY'),//塞浦路斯
          Locale('zh', 'HK'),//香港
          Locale('de', 'DE'),//德国
          Locale('el', 'GR'),//希腊
          Locale('en', 'IN'),//印度
          Locale('en', 'IE'),//爱尔兰
          Locale('it', 'IT'),//意大利
          Locale('ja', 'JP'),//日本
          Locale('kk', 'KZ'),//哈萨克斯坦
          Locale('sw', 'KE'),//肯尼亚
          Locale('ko', 'KR'),//韩国
          Locale('ar', 'KW'),//科威特
          Locale('ky', 'KG'),//吉尔吉斯斯坦
          Locale('lo', 'LA'),//老挝
          Locale('lv', 'LV'),//拉脱维亚
          Locale('ar', 'LB'),//黎巴嫩
          Locale('lt', 'LT'),//立陶宛
          Locale('de', 'LU'),//卢森堡
          Locale('zh', 'MO'),//澳门特别行政区
          Locale('fr', 'MG'),//马达加斯加
          Locale('en', 'MY'),//马来西亚
          Locale('dv', 'MV'),//马尔代夫
          Locale('en', 'MU'),//毛里求斯
          Locale('es', 'MX'),//墨西哥
          Locale('ro', 'MD'),//摩尔多瓦
          Locale('fr', 'MC'),//摩纳哥
          Locale('mn', 'MN'),//蒙古
          Locale('sr', 'ME'),//黑山
          Locale('ar', 'MA'),//摩洛哥
          Locale('en', 'MM'),//缅甸
          Locale('en', 'NR'),//瑙鲁
          Locale('ne', 'NP'),//尼泊尔
          Locale('nl', 'NL'),//荷兰
          Locale('en', 'NZ'),//新西兰
          Locale('fr', 'NE'),//尼日尔
          Locale('ha', 'NG'),//尼日利亚
          Locale('mk', 'MK'),//北马其顿
          Locale('nb', 'NO'),//挪威
          Locale('ar', 'OM'),//阿曼
          Locale('en', 'PK'),//巴基斯坦
          Locale('en', 'PW'),//帕劳
          Locale('es', 'PA'),//巴拿马
          Locale('en', 'PG'),//巴布亚新几内亚
          Locale('es', 'PY'),//巴拉圭
          Locale('es', 'PE'),//秘鲁
          Locale('en', 'PH'),//菲律宾
          Locale('pl', 'PL'),//波兰
          Locale('es', 'PR'),//波多黎各
          Locale('ar', 'QA'),//卡塔尔
          Locale('ro', 'RO'),//罗马尼亚
          Locale('ru', 'RU'),//俄罗斯
          Locale('rw', 'RW'),//卢旺达
          Locale('ar', 'SA'),//沙特阿拉伯
          Locale('wo', 'SN'),//塞内加尔
          Locale('sr', 'RS'),//塞尔维亚
          Locale('en', 'SC'),//塞舌尔
          Locale('en', 'SG'),//新加坡
          Locale('zh', 'SG'),//新加坡
          Locale('sk', 'SK'),//斯洛伐克
          Locale('sl', 'SI'),//斯洛文尼亚
          Locale('en', 'SB'),//所罗门群岛
          Locale('ar', 'SO'),//索马里
          Locale('en', 'ZA'),//南非
          Locale('en', 'SS'),//南苏丹
          Locale('es', 'ES'),//西班牙
          Locale('ca', 'ES'),//西班牙
          Locale('eu', 'ES'),//西班牙
          Locale('gl', 'ES'),//西班牙
          Locale('en', 'ES'),//西班牙
          Locale('si', 'LK'),//斯里兰卡
          Locale('nl', 'SR'),//苏里南
          Locale('se', 'SE'),//瑞典
          Locale('de', 'CH'),//瑞士
          Locale('fr', 'CH'),//瑞士
          Locale('it', 'CH'),//瑞士
          Locale('zh', 'TW'),//台湾
          Locale('tg', 'TJ'),//塔吉克斯坦
          Locale('en', 'TZ'),//坦桑尼亚
          Locale('th', 'TH'),//泰国
          Locale('pt', 'TL'),//东帝汶
          Locale('en', 'TO'),//汤加
          Locale('ar', 'TN'),//突尼斯
          Locale('tr', 'TR'),//土耳其
          Locale('tk', 'TM'),//土库曼斯坦
          Locale('en', 'UG'),//乌干达
          Locale('uk', 'UA'),//乌克兰
          Locale('ar', 'AE'),//阿拉伯联合酋长国
          Locale('en', 'GB'),//英国
          Locale('en', 'UM'),//美国本土外小岛屿
          Locale('en', 'VI'),//美国维尔京群岛
          Locale('es', 'UY'),//乌拉圭
          Locale('uz', 'UZ'),//乌兹别克斯坦
          Locale('es', 'VE'),//委内瑞拉
          Locale('ar', 'YE'),//也门
          Locale('en', 'ZM'),//赞比亚
          Locale('en', 'ZW'),//津巴布韦
          // ... other locales the app supports
        ],
        home: const MainPage(),
      ),
    );
  }
}


