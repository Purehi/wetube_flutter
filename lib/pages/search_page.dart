import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:localstorage/localstorage.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/components/video_card.dart';
import 'package:you_tube/model/api_manager.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/components/suggestion_card.dart';
import 'package:you_tube/pages/channel_page.dart';
import 'package:you_tube/pages/empty_page.dart';
import 'package:you_tube/components/sports_card.dart';
import 'package:you_tube/pages/loading_page.dart';
import 'package:you_tube/pages/youtube_player_page.dart';
import '../model/youtube_link_manager.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _queryKeyword = '';
  String _searchKeyword = '';
  String? _token;
  List<Video> _videos = [];
  bool _isResultNotFound = false;
  bool _isQueryKeyword = false;
  bool _isQuery = false;
  List<String> _suggestions = [];
  final txt = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoadingData = false;
  String _searchTips = 'Search';
  String _searchTitle = 'Try searching to get started.';
  String _searchSubtitle = 'Start watching videos to help us build a feed of videos you\'ll love.';
  final _videoKey = UniqueKey();

  @override
  void initState() {
    final searchTitle = localStorage.getItem('searchTitle');
    final searchSubtitle = localStorage.getItem('searchSubtitle');
    final searchTips = localStorage.getItem('searchTips');
    if(searchTips != null){
      _searchTitle = searchTitle ?? _searchTitle;
      _searchSubtitle = searchSubtitle ?? _searchSubtitle;
      _searchTips = searchTips;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // executes after build
      FocusScope.of(context).requestFocus(_focusNode);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MediaQuery (
      data: MediaQuery.of(context).scale(),
      child: Scaffold(
          backgroundColor: defaultColorScheme.surface,
          appBar: AppBar(
            backgroundColor: defaultColorScheme.surface,
            scrolledUnderElevation:0.0,
            shadowColor: Colors.transparent,
            elevation: 0.0,
            leading: BackButton(
              style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
              color: defaultColorScheme.primary,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 20),
                    height: 40,
                    child: TextField(
                      style: textTheme.titleMedium?.copyWith(color:defaultColorScheme.primary),
                      controller: txt,
                      focusNode: _focusNode,
                      onChanged: (query) {
                        txt.text = query;
                        if(query.isNotEmpty){
                          _fetchKeyword(query);
                        }
                      },
                      onSubmitted: (query){
                        txt.text = query;
                        if(query.isNotEmpty){
                          _fetchStream(query);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: defaultColorScheme.onPrimaryContainer,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                        /* -- Text and Icon -- */
                        hintText: _searchTips,
                        hintStyle: textTheme.titleMedium?.copyWith(color:defaultColorScheme.onPrimary),// TextStyle
                        suffixIcon: IconButton(
                          /// clear text
                          onPressed: (){
                            txt.text = '';
                            setState(() {
                              _isQueryKeyword = false;
                              _suggestions = [];
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: defaultColorScheme.onPrimary,
                          ),
                        ), // Icon
                        /* -- Border Styling -- */
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            width: 2.0,
                            color: Colors.transparent,
                          ), // BorderSide
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            width: 2.0,
                            color: Colors.transparent,
                          ), // BorderSide
                        ), // OutlineInputBorder
                      ), // InputDecoration
                    ),
                  ),
                ),
              ],
            ),
            // actions: phone2340 ? [back] : null,
          ),
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildWideLayout();
                  } else {
                    return _buildNarrowLayout();
                  }
                },
              ),
              if(_isQueryKeyword) Container(
                color: defaultColorScheme.surface,
                // height: MediaQuery.of(context).size.height * 0.62,
                child: ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: _suggestions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                        onTap: (){
                          FocusManager.instance.primaryFocus?.unfocus();
                          txt.text = suggestion;
                          setState(() {
                            _isQueryKeyword = false;
                            _isQuery = true;
                          });
                          _fetchStream(suggestion);
                        },
                        child:SuggestionCard(text: suggestion));
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
  Widget _buildNarrowLayout() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    final itemHeight = screenWidth * 9 / 16 + 50;
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if(_videos.isNotEmpty){
      return MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView.separated(
            primary: true,
            cacheExtent: itemHeight,
            itemBuilder: (context, index) {
              final video = _videos[index];
              if(index == _videos.length - 1){
                if(_token != null){
                  _fetchStreamContinuation(_token!);
                }
                return Column(children: [
                  VideoCard(
                    key: _videoKey,
                    video: video,
                    onTapAvatar: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChannelPage(browseId: video.browseId),));
                    }, onTap: () {
                    PictureInPicture.stopPiP();
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                      builder: (_) => YoutubePlayerPage(video: video),));
                  },),
                  SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: defaultColorScheme.primary,),
                  )
                ],);
              }
              return VideoCard(
                key: _videoKey,
                video: video,
                onTapAvatar: (){
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChannelPage(browseId: video.browseId),));
                }, onTap: () {
                PictureInPicture.stopPiP();
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (_) => YoutubePlayerPage(video: video),));
              },);
            },
            separatorBuilder: (context, position) {
              return const SizedBox.shrink();
            },
            itemCount: _videos.length,
          )
      );
    }else if(_isQuery){
      return const LoadingPage();
    }else if(!_isQuery && _videos.isEmpty){
      final padding = MediaQuery.of(context).padding;
      return Column(
        spacing: 20.0,
        children: [
          Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 10).copyWith(top: padding.top),
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
            child: Column(children: [
              Text(_isResultNotFound ? 'Sorry, Please try changing the keywords' : _searchTitle,
                  style: textTheme.titleLarge?.copyWith(
                      color: defaultColorScheme.primary,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center),
              Text(_isResultNotFound ? 'Sorry, Please try changing the keywords' : _searchSubtitle,
                  style: textTheme.bodyMedium?.copyWith( color: defaultColorScheme.primary),
                  textAlign: TextAlign.center),
            ],),
          ),
        ],
      );
    }
    return EmptyPage(onTap: (){
      if(txt.text.isNotEmpty){
        _fetchStream(txt.text);
      }
    },);
  }
  Widget _buildWideLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    final itemHeight = ((screenWidth - 36.0) / 2.0) * 0.75;
    int length = _videos.length ~/ 2;
    if(_videos.isNotEmpty){
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.separated(
          cacheExtent: itemHeight,
          itemBuilder: (context, index) {
            final items = _videos.sublist(index * 2, index * 2+2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 12.0),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // number of items in each row
                    mainAxisSpacing: 12.0, // spacing between rows
                    crossAxisSpacing: 12.0, // spacing between columns
                    childAspectRatio: 4/3,
                  ), // padding around the grid
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    final video = items[index];
                    return SportsCard(
                      video: video,
                      onTapAvatar: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChannelPage(browseId: video.browseId)));
                      }, onTap: () {
                      YoutubeLinkManager.shared.getYouTubeURL(video);
                      PictureInPicture.stopPiP();
                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                        builder: (_) => YoutubePlayerPage(video: video),));
                    },);
                  }),
            );
          },
          separatorBuilder: (context, position) {
            return const SizedBox.shrink();
          },
          itemCount: length,
        ),
      );
    }else if(_isQuery){
      return const LoadingPage();
    }else if(!_isQuery && _videos.isEmpty){
      return Padding(
        padding: const EdgeInsets.only(top: 220),
        child: Align(
            alignment: Alignment.center,
            child: Text(_isResultNotFound ? 'Sorry, Please try changing the keywords' : _searchTitle,
                style: textTheme.headlineMedium!.copyWith( color: defaultColorScheme.primary),
                textAlign: TextAlign.center)),
      );
    }
    return EmptyPage(onTap: (){
      if(txt.text.isNotEmpty){
        _fetchStream(txt.text);
      }
    },);
  }

  void _fetchStream(String keyword) async {
    if(keyword != _searchKeyword && keyword != ''){
      _searchKeyword = keyword;
      _videos = [];
      _token = null;
      _isResultNotFound = false;
      setState(() {
        _isQuery = true;
        _isQueryKeyword = false;
      });
      fetchWebSearchDataWithNoToken(keyword, (int statusCode, Map<String, dynamic>? result){
        _isQuery = false;
        _searchKeyword = '';
        _isQueryKeyword = false;
        final videos = result?['videos'];
        if(videos != null && videos.isNotEmpty){
          _token = result?['token'];
          setState(() {
            _videos.addAll(videos);
          });
        }else{
          setState(() {});
        }
      });
    }
  }
  void _fetchStreamContinuation(String token) async {
    if(_isLoadingData)return;
    _isLoadingData = true;
    fetchWebSearchContinuationDataWithNoToken(token, (int statusCode, Map<String, dynamic>? result){
      _isQuery = false;
      _searchKeyword = '';
      _isQueryKeyword = false;
      _isLoadingData = false;
      final videos = result?['videos'];
      if(videos != null && videos.isNotEmpty){
        _token = result?['token'];
        setState(() {
          _videos.addAll(videos);
        });
      }else{
        setState(() {});
      }
    });
  }
  // keyword
  void _fetchKeyword(String keyword) async {
    if (keyword != _queryKeyword){
      _queryKeyword = keyword;
      _isQueryKeyword  = false;
      fetchWebSuggestionNoToken(keyword, (int statusCode, Map<String, dynamic>? result){
        final List<String>? suggestions = result?['suggestions'];
        if(suggestions != null && suggestions.isNotEmpty){
          setState(() {
            _isQueryKeyword = true;
            _suggestions = suggestions;
          });
        }else{
          setState(() {
            _isQueryKeyword  = false;
          });
        }
      });
    }
  }
}
