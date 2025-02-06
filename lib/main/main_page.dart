import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/home/home_page.dart';
import 'package:you_tube/model/my_shared_preferences.dart';
import 'package:you_tube/music/music_section_page.dart';
import 'package:you_tube/pages/live_video_page.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:you_tube/model/country.dart';
import 'package:you_tube/pages/sport_page.dart';
import '../model/api_manager.dart';
import '../model/data.dart';
import '../model/youtube_client.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  List<TabRenderer> _tabRenderers = [];
  List<PlaylistSection> _sections = [];
  final String _cacheTabRenderKey = 'home_tab_render_cache';
  final String _cacheSectionKey = 'home_section_cache';

  @override
  void initState() {
    //process data
    WidgetsBinding.instance.addPostFrameCallback((_){
      _handleData();
    });
    ///更改国家
    _countryCodeChangedListener();
    super.initState();
  }

  Future<void> _cacheTabRender(String key, Duration duration, List<TabRenderer> sections) async{
    final jsonString = sections.map((section) => section.toJSONEncodable()).toList();
    final str = jsonEncode(jsonString);
    MySharedPreferences.saveDataWithExpiration(key, str, duration);
  }
  Future<List<TabRenderer>?> _loadTabRenderSections(String key) async{
    final result = await MySharedPreferences.getDataIfNotExpired(key);
    if(result != null){
      final List<dynamic> results = jsonDecode(result);
      final List<TabRenderer> sections = List<TabRenderer>.from(results.map((result)=> TabRenderer.fromJson(result)).toList());
      return sections;
    }
    return null;
  }
  Future<void> _cacheSections(String key, Duration duration, List<PlaylistSection> sections) async{
    final jsonString = sections.map((section) => section.toJson()).toList();
    final str = jsonEncode(jsonString);
    MySharedPreferences.saveDataWithExpiration(key, str, duration);
  }
  Future<List<PlaylistSection>?> _loadSections(String key) async{
    final result = await MySharedPreferences.getDataIfNotExpired(key);
    if(result != null){
      final List<dynamic> results = jsonDecode(result);
      final List<PlaylistSection> sections = List<PlaylistSection>.from(results.map((result)=> PlaylistSection.fromJson(result)).toList());
      return sections;
    }
    return null;
  }
  //处理流行数据
  Future<void> _handlePopularData(String languageCode, String countryCode) async {
    MySharedPreferences.ifExpired(_cacheTabRenderKey).then((isExpirationTime) async {
      if(isExpirationTime){//获取最新数据
        final local = Locale(languageCode , countryCode);
        fetchHomeDataWithNoToken(local, (int statusCode, Map<String, dynamic> result){
          final List<PlaylistSection> sections = result['sections'];
          final List<TabRenderer> tabRenderers = result['tabRenderers'];
          final pageTitle = result['pageTitle'];
          if(tabRenderers.isNotEmpty){
            setState(() {
              _sections.addAll(sections);
              _tabRenderers.addAll(tabRenderers);
            });
            //cache data
            if(pageTitle != null){
              localStorage.setItem('trendingPageTitle', pageTitle);
            }
            _cacheSections(_cacheSectionKey, const Duration(days: 1),sections);
            _cacheTabRender(_cacheTabRenderKey, const Duration(days: 1),tabRenderers);
          }
        });
      }else{
        final tabRenderers = await _loadTabRenderSections(_cacheTabRenderKey);
        final sections = await _loadSections(_cacheSectionKey);//加载缓存
        if(tabRenderers != null && tabRenderers.isNotEmpty && sections != null){
          setState(() {
            _sections.addAll(sections);
            _tabRenderers.addAll(tabRenderers);
          });
        }else{
          final local = Locale(languageCode , countryCode);
          fetchHomeDataWithNoToken(local, (int statusCode, Map<String, dynamic> result){
            final List<PlaylistSection> sections = result['sections'];
            final List<TabRenderer> tabRenderers = result['tabRenderers'];
            final pageTitle = result['pageTitle'];
            if(tabRenderers.isNotEmpty){
              setState(() {
                _sections.addAll(sections);
                _tabRenderers.addAll(tabRenderers);
              });
              //cache data
              if(pageTitle != null){
                localStorage.setItem('trendingPageTitle', pageTitle);
              }
              _cacheSections(_cacheSectionKey, const Duration(days: 1),sections);
              _cacheTabRender(_cacheTabRenderKey, const Duration(days: 1),tabRenderers);
            }
          });
        }
      }
    });
  }
  void _handleData(){
    var country = localStorage.getItem('countryCode');
    var language = localStorage.getItem('languageCode');
    if(country == null && language == null){
      if(mounted){
        Locale myLocale = Localizations.localeOf(context);
        bool isRemove = removeSomeCountry(myLocale.countryCode);
        if(isRemove){//不支持的地区设置默认值
          country = 'US';
          language = 'en';
        }else{
          final filter = filterSomeCountry(myLocale.countryCode);
          country = filter ?? myLocale.countryCode;
          language = myLocale.languageCode;
        }
      }
    }
    countryCode = country;
    languageCode = language;
    _handlePopularData(languageCode ?? 'en', countryCode ?? 'US');

  }
  ///更改国家
  void _countryCodeChangedListener(){
    countryCodeChanged.addListener(() async {
      if(countryCodeChanged.value == true){
        setState(() {
          _sections = [];
          _tabRenderers = [];
          _currentIndex = 0;
        });
        localStorage.removeItem('homeTitleTips');
        localStorage.removeItem('homeSubtitleTips');
        localStorage.removeItem('homeCtaTips');

        MySharedPreferences.clearData('music_channel_cache');
        MySharedPreferences.clearData(_cacheTabRenderKey);
        MySharedPreferences.clearData(_cacheSectionKey);

        _handleData();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          APIRequest.shared.isTablet = true;
          if(_tabRenderers.isNotEmpty){
            return _buildNarrowLayout();
          }
          final defaultColorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              shadowColor: Colors.transparent,
              elevation: 0.0,
              backgroundColor: defaultColorScheme.surface,
              excludeHeaderSemantics: true,
              // question having 0 here
              title: Text('WeTube',
                style: textTheme.titleLarge?.copyWith(
                  // fontWeight: FontWeight.bold,
                    color: defaultColorScheme.secondary),),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.account_circle_outlined, color: defaultColorScheme.secondary),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 24),
                  child: Icon(Icons.search,
                      color: defaultColorScheme.secondary),
                ),
              ],),
            body: LoadingPage(),);
        } else {
          APIRequest.shared.isTablet = false;
          if(_tabRenderers.isNotEmpty){
            return _buildNarrowLayout();
          }
          final defaultColorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            appBar: AppBar(
                scrolledUnderElevation: 0.0,
                shadowColor: Colors.transparent,
                elevation: 0.0,
                backgroundColor: defaultColorScheme.surface,
                excludeHeaderSemantics: true,
                // question having 0 here
                title: Text('WeTube',
                  style: textTheme.titleLarge?.copyWith(
                    // fontWeight: FontWeight.bold,
                      color: defaultColorScheme.secondary),),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.account_circle_outlined, color: defaultColorScheme.secondary),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 24),
                    child: Icon(Icons.search,
                        color: defaultColorScheme.secondary),
                  ),
                ],),
            body: LoadingPage(),);
        }
      },
    );
  }
  Widget _buildNarrowLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    return MediaQuery(
        data: MediaQuery.of(context).scale(),
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index){
              setState(() {
                _currentIndex = index;
              });
              currentIndexKey = index;
            },
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            selectedItemColor: Color(0xff42C83C),
            unselectedItemColor: defaultColorScheme.onPrimary,
            backgroundColor: defaultColorScheme.surface,
            iconSize: 26,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.subscriptions_outlined),
                activeIcon: Icon(Icons.subscriptions_rounded),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.newspaper_outlined),
                activeIcon: Icon(Icons.newspaper_rounded),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon:  Icon(Icons.library_music_outlined),
                activeIcon: Icon(Icons.library_music_rounded),
                label: '',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, result){
                  // This can be async and you can check your condition
                  final navigator = navigatorKey.currentState;
                  final currentContext = navigatorKey.currentContext;
                  if (navigator != null && navigator.canPop() && currentContext != null && _currentIndex == 0){
                    Navigator.of(currentContext).pop();
                  }
                },
                child: Navigator(
                  key: navigatorKey,
                  onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                      settings: settings,
                      builder: (BuildContext context) => HomePage(sections: _sections, tabRenderers: _tabRenderers,)
                    //MainPage
                  ),
                ),
              ),
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, result){
                  // This can be async and you can check your condition
                  final navigator = subscriptionNavigatorKey.currentState;
                  final currentContext = subscriptionNavigatorKey.currentContext;
                  if (navigator != null && navigator.canPop() && currentContext != null && _currentIndex == 2){
                    Navigator.of(currentContext).pop();
                  }
                },
                child: Navigator(
                  key: subscriptionNavigatorKey,
                  onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                      settings: settings,
                      builder: (BuildContext context) => const SportPage()
                    //MainPage
                  ),
                ),
              ),
              PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (bool didPop, result){
                    // This can be async and you can check your condition
                    final navigator = newsNavigatorKey.currentState;
                    final currentContext = newsNavigatorKey.currentContext;
                    if (navigator != null && navigator.canPop() && currentContext != null && _currentIndex == 3){
                      if (mounted) Navigator.of(currentContext).pop();
                    }
                  },
                  child: Navigator(
                    key: newsNavigatorKey,
                    onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                        settings: settings,
                        builder: (BuildContext context) => const LiveVideoPage()
                      //MainPage
                    ),
                  )
              ),
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, result){
                  // This can be async and you can check your condition
                  final navigator = musicNavigatorKey.currentState;
                  final currentContext = musicNavigatorKey.currentContext;
                  if (navigator != null && navigator.canPop() && currentContext != null && _currentIndex == 4){
                    Navigator.of(currentContext).pop();
                  }
                },
                child: Navigator(
                  key: musicNavigatorKey,
                  onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
                      settings: settings,
                      builder: (BuildContext context) => const MusicSectionPage()
                    //MainPage
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

