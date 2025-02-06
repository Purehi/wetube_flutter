import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/home/home_video_page.dart';
import 'package:you_tube/model/country.dart';
import 'package:you_tube/pages/country_page.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/pages/search_page.dart';
import 'package:you_tube/model/data.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:you_tube/subscription/setting_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/youtube_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key,
    required this.sections,
    required this.tabRenderers});
  final List<PlaylistSection> sections;
  final List<TabRenderer> tabRenderers;
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  final List<PlaylistSection> _sections = [];
  final List<TabRenderer> _tabRenderers = [];
  String? _titleText;

  final String _titleTips = 'Don’t miss new videos';
  final String _subtitleTips = 'Get app from google play store.';
  final String _ctaTips = 'Get it';

  @override
  void initState() {
    _tabRenderers.addAll(widget.tabRenderers);
    _sections.addAll(widget.sections);
    _titleText = _getCounties(Locale(languageCode ?? 'en', countryCode ?? 'US'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme
        .of(context)
        .colorScheme;
    final textTheme = Theme
        .of(context)
        .textTheme;
    if (_tabRenderers.isNotEmpty) {
      return MediaQuery(
          data: MediaQuery.of(context).scale(),
          child: DefaultTabController(
            length: _tabRenderers.length,
            child: ExtendedNestedScrollView(
              onlyOneScrollInBody: true,
              floatHeaderSlivers: true,
              headerSliverBuilder: (BuildContext context,
                  bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      scrolledUnderElevation: 0.0,
                      shadowColor: Colors.transparent,
                      elevation: 0.0,
                      toolbarHeight: kToolbarHeight * 1.5,
                      backgroundColor: defaultColorScheme.surface,
                      excludeHeaderSemantics: true,
                      // question having 0 here
                      title: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const CountryPage()));
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Text(_titleText ?? 'WeTube',
                                style: textTheme.titleLarge?.copyWith(
                                  // fontWeight: FontWeight.bold,
                                    color: defaultColorScheme.secondary),),
                              Icon(Icons.arrow_drop_down_rounded,
                                color: defaultColorScheme.secondary,),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SettingPage()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(Icons.account_circle_outlined,
                                color: defaultColorScheme.secondary),
                          ),),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const SearchPage()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 24),
                            child: Icon(Icons.search,
                                color: defaultColorScheme.secondary),
                          ),),
                      ],
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(0),
                          child: TabBar(
                            padding: EdgeInsets.zero,
                            tabAlignment: TabAlignment.start,
                            labelColor: Color(0xff42C83C),
                            indicatorSize: TabBarIndicatorSize.tab,
                            unselectedLabelColor: defaultColorScheme.secondary
                                .withValues(alpha: 0.8),
                            unselectedLabelStyle: textTheme.titleMedium,
                            labelStyle: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold
                            ),
                            indicatorColor: Colors.transparent,
                            isScrollable: true,
                            tabs: widget.tabRenderers
                                .asMap()
                                .map((i, element) =>
                                MapEntry(
                                    i, Tab(text: element.title, height: 34,)))
                                .values
                                .toList(),
                          )
                      )),
                  SliverToBoxAdapter(child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: defaultColorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: defaultColorScheme.onPrimaryContainer,
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(_titleTips,
                                style: textTheme.titleMedium?.copyWith(
                                    color: defaultColorScheme.primary,
                                    fontWeight: FontWeight.bold
                                ),),
                            Text(_subtitleTips,
                                style: textTheme.bodyMedium?.copyWith( color: defaultColorScheme.primary),
                                ),
                          ],),
                        ),
                        InkWell(
                          onTap:() async{
                            final appId = 'free.mor.mordo.do';
                            final url = Uri.parse("market://details?id=$appId");
                            launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color(0xff42C83C)
                            ),
                            child: Text(
                              _ctaTips,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),)
                ];
              },
              body: TabBarView(
                  children: (_tabRenderers.asMap().map((i, element) =>
                      MapEntry(i,
                          HomeVideoPage(
                            tabRenderer: element, items: i == 0 ? _sections : [],)
                      )).values.toList())
              ),
            ),
          ));
    }
    return Scaffold(
        backgroundColor: defaultColorScheme.surface,
        appBar: AppBar(
          backgroundColor: defaultColorScheme.surface,
          scrolledUnderElevation: 0.0,
          shadowColor: Colors.transparent,
          elevation: 0.0,
          title: Text('WeTube', style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: defaultColorScheme.primary
          ), overflow: TextOverflow.ellipsis,),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SettingPage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.account_circle_outlined,
                    color: defaultColorScheme.secondary),
              ),),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SearchPage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 24),
                child: Icon(
                    Icons.search, color: defaultColorScheme.secondary),
              ),),
          ],
        ),
        body: const LoadingPage());
  }
  String? _getCounties(Locale locale){
    ///获取国家
    final countries = getAllCounties(locale);
    final countryCode = locale.countryCode;
    final titleText = countries[countryCode];
    return titleText;
  }
}
