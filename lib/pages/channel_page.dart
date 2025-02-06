import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/pages/channel_video_page.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/pages/search_page.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({super.key, this.browseId});
  final String? browseId;

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> with TickerProviderStateMixin{

  ChannelProfileModel? _channelProfileModel;
  final List<Video> _videos = [];
  final List<TabRenderer> _tabRenderers = [];

  @override
  void initState() {
    super.initState();
    // executes after build
    final browseId = widget.browseId ?? "UCBR8-60-B28hp2BmDPdntcQ";
    fetchChannelWithNoToken(browseId, (int statusCode, Map<String, dynamic>? result){
      final channel = result?['channel'];
      final tabRenderers = result?['tabRenderers'];
      final videos = result?['videos'];
      if(tabRenderers != null){
        _tabRenderers.addAll(tabRenderers);
      }
      if(videos != null){
        _videos.addAll(videos..shuffle());
      }
      setState(() {
        _channelProfileModel = channel;
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }
  Widget _buildNarrowLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        backgroundColor: defaultColorScheme.surface,
        appBar: AppBar(
          leading: BackButton(
            style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
            color: defaultColorScheme.primary,),
          scrolledUnderElevation:0.0,
          shadowColor: Colors.transparent,
          elevation: 0.0,
          title: Text(
            _channelProfileModel?.title ?? '',
            style: textTheme.headlineSmall!.copyWith(
              color: defaultColorScheme.primary,
            ),
          ),
          backgroundColor: defaultColorScheme.surface,
          actions: [
            InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SearchPage()));
              },
              child: Icon(Icons.search, color: defaultColorScheme.secondary),),
            const SizedBox(width: 12,),
          ],
        ),
        body: DefaultTabController(
          length: _tabRenderers.length,
          child: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              double headerHeight = 108.0;
              if(APIRequest.shared.canRequestAds){
                headerHeight += 60.0;
              }
              if(_channelProfileModel?.banner != null){
                headerHeight += 88.0;
              }
              return [
                SliverAppBar(
                  collapsedHeight: headerHeight,
                  expandedHeight: headerHeight,
                  flexibleSpace: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_channelProfileModel?.banner != null) Container(
                        height: 88.0,
                        width: double.infinity,
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image:
                                NetworkImage(_channelProfileModel!.banner!),
                                fit: BoxFit.cover
                            )
                        ),
                      ),
                      if(_channelProfileModel?.avatar != null)Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 20.0,
                            backgroundImage:
                            NetworkImage(_channelProfileModel!.avatar!),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(_channelProfileModel?.title ?? '',style: textTheme.titleMedium!.copyWith(
                                    color: defaultColorScheme.primary,
                                    fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(_channelProfileModel?.metadata ?? '',style: textTheme.bodyMedium!.copyWith(
                                  color: defaultColorScheme.onPrimary,), maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ),
                            ],),
                        ],),
                      ),
                    ],
                  ),
                  backgroundColor: defaultColorScheme.surface,
                  automaticallyImplyLeading: false,
                ),
                //page of tab
                if(_tabRenderers.isNotEmpty)SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverPersistentHeaderDelegateImpl(
                      tabBar: TabBar(
                        tabAlignment: TabAlignment.start,
                        labelColor: defaultColorScheme.primary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: defaultColorScheme.secondary.withValues(alpha: 0.8),
                        unselectedLabelStyle: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                        labelStyle: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                        indicatorColor: Colors.transparent,
                        indicator: UnderlineTabIndicator(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          borderSide: BorderSide(color: defaultColorScheme.primary),
                          insets: EdgeInsets.symmetric(horizontal:16.0, vertical: 10.0),
                        ),
                        isScrollable: true,
                        tabs: _tabRenderers.asMap().map((i, element) => MapEntry(i, Tab(text: element.title,))).values.toList(),
                      ),
                      color: defaultColorScheme.surface
                  ),
                ),
                if(_tabRenderers.isEmpty)SliverToBoxAdapter(child: LoadingPage(),)
              ];
            },
            body: TabBarView(
              children: _tabRenderers.asMap().map((i, element) =>
                  MapEntry(i,
                      ChannelVideoPage(tabRenderer: element, videos: i == 0 ? _videos : null,)
                  )).values.toList(),
            ),
          ),
        )
    );
  }
  Widget _buildWideLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        backgroundColor: defaultColorScheme.surface,
        appBar: AppBar(
          leading: BackButton(
            color: defaultColorScheme.primary,
          ),
          title: Text(
            _channelProfileModel?.title ?? '',
            style: textTheme.headlineMedium!.copyWith(
              color: defaultColorScheme.primary,
            ),
          ),
          // backgroundColor: const Color(0xffd50506),
          backgroundColor: defaultColorScheme.surface,
        ),
        body: DefaultTabController(
          length: _tabRenderers.length,
          child: NestedScrollView(
            physics: const NeverScrollableScrollPhysics(),
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              var height = 114.0;
              if(_channelProfileModel?.banner != null){
                height += 88.0;
              }
              if(APIRequest.shared.canRequestAds){
                height += 60.0;
              }
              return [
                SliverAppBar(
                  collapsedHeight: height,
                  expandedHeight: height,

                  flexibleSpace: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_channelProfileModel?.banner != null)Container(
                        height: 88.0,
                        width: double.infinity,
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image:
                                NetworkImage(_channelProfileModel!.banner!),
                                fit: BoxFit.cover
                            )
                        ),
                      ),
                      if(_channelProfileModel?.avatar != null)Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage:
                            NetworkImage(_channelProfileModel!.avatar!),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_channelProfileModel?.title ?? '',style: textTheme.headlineSmall!.copyWith(
                                  color: defaultColorScheme.primary,
                                  fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                              Text(_channelProfileModel?.channelHandle ?? '',style: textTheme.bodyMedium!.copyWith(
                                  color: defaultColorScheme.onPrimary,)),
                              Text(_channelProfileModel?.metadata ?? '',style: textTheme.bodyMedium!.copyWith(
                                  color: defaultColorScheme.onPrimary,)),
                            ],),
                        ],),
                      ),
                      //show banner ad
                    ],
                  ),
                  backgroundColor: defaultColorScheme.surface,
                  automaticallyImplyLeading: false,
                ),
                if(_tabRenderers.isNotEmpty)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverPersistentHeaderDelegateImpl(
                        tabBar: TabBar(
                          // controller: _tabController,
                          tabAlignment: TabAlignment.start,
                          labelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          unselectedLabelColor: defaultColorScheme.secondary,
                          unselectedLabelStyle: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold
                          ),
                          labelStyle: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold
                          ),
                          indicatorWeight: 4,
                          indicatorPadding: const EdgeInsets.symmetric(vertical: 10).copyWith(
                              left: 2,
                              right: 2
                          ),
                          indicator: ShapeDecoration(
                            color: const Color(0xff009a3d),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),),
                          isScrollable: true,
                          tabs: _tabRenderers.asMap().map((i, element) => MapEntry(i, Tab(text: element.title,))).values.toList(),
                        ),
                        color: defaultColorScheme.surface
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: LoadingPage(),
                  ),
              ];
            },
            //page
            body: TabBarView(
              children: _tabRenderers.asMap().map((i, element) =>
                  MapEntry(i,
                      ChannelVideoPage(tabRenderer: element, videos: i == 0 ? _videos : null,)
                  )).values.toList(),
            ),
          ),
        )
    );
  }
}
class SliverPersistentHeaderDelegateImpl extends SliverPersistentHeaderDelegate {
  final TabBar? tabBar;
  final Color color;

  const SliverPersistentHeaderDelegateImpl({
    this.color = Colors.white,
    required this.tabBar,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: tabBar,
    );
  }

  @override
  double get maxExtent =>  (tabBar != null) ? tabBar!.preferredSize.height : 0.0;

  @override
  double get minExtent => (tabBar != null) ? tabBar!.preferredSize.height : 0.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
