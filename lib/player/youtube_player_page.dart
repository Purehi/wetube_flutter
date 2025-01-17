import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wetube_flutter/widgets/video_card.dart';
import 'package:youtube_data_api/models/video.dart';
import 'package:youtube_data_api/models/video_data.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerPage extends StatefulWidget {
  const YoutubePlayerPage({super.key, required this.video});
  final Video video;

  @override
  State<YoutubePlayerPage> createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  bool _isExpand = false;
  VideoData? _videoData;
  YoutubePlayerController? _youtubePlayerController;
  @override
  void initState() {

    if(widget.video.videoId != null){
      YoutubeDataApi youtubeDataApi = YoutubeDataApi();
      youtubeDataApi.fetchVideoData(widget.video.videoId!).then((videoData){
        setState(() {
          _videoData = videoData;
        });
      });
      //init player controller
      _youtubePlayerController = _initVideoPlayerController(widget.video);
    }

    super.initState();
  }
  //load video
  YoutubePlayerController _initVideoPlayerController(Video video) {
    final controller = YoutubePlayerController(
      initialVideoId: video.videoId!,
      flags: YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: true,
          forceHD: false,
          enableCaption: false,
      ),
    );
    return controller;
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          if(_youtubePlayerController != null)SliverPersistentHeader(
              floating: false,
              pinned: true,
              delegate: SliverAppBarDelegate(
                minHeight: screenWidth * 9 / 16,
                maxHeight: screenWidth * 9 / 16,
                child:YoutubePlayer(
                  controller: _youtubePlayerController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Color(0xff42C83C),
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.amber,
                    handleColor: Colors.amberAccent,
                  ),
                  onReady: (){
                    // Needed, since the play and mute are delayed when passed as flags.
                    _youtubePlayerController?.play();
                  },
                  bottomActions: [
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    SizedBox(width: 8.0),
                    ProgressBar(isExpanded: true,
                      colors: const ProgressBarColors(
                          playedColor: Colors.amber,
                          handleColor: Colors.amberAccent,
                          backgroundColor: Colors.white
                      ),),
                    RemainingDuration(),
                    SizedBox(width: 8.0),
                    const PlaybackSpeedButton(),
                    const SizedBox(width: 14.0),
                  ],
                  topActions: [
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.white,
                        size: 50.0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Spacer(),
                  ],
                ),
              ))
          else
            SliverPersistentHeader(
                floating: false,
                pinned: true,
                delegate: SliverAppBarDelegate(
                  minHeight: screenWidth * 9 / 16,
                  maxHeight: screenWidth * 9 / 16,
                  child:AspectRatio(
                    aspectRatio: 16/9,
                    child:CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      imageUrl: widget.video.thumbnails!.first.url!,
                      // width: screenWidth,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                )),
          SliverToBoxAdapter(child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // owner
                if(_videoData?.video?.channelThumb != null ) InkWell(
                  child: CachedNetworkImage(
                    imageUrl: _videoData!.video!.channelThumb!,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(22)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(color: Colors.black12),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black12,
                      child: const Icon(Icons.error, color: Color(0xffe2001d),size: 40.0),
                    ),
                  ),
                ),
                const SizedBox(width: 5,),
                Expanded(child:  Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // title
                    Text(
                      widget.video.title!,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                      ),
                      maxLines: _isExpand ? 50 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 10,),
                    // subtitle
                    Text(
                      "${widget.video.channelName!}·${_videoData?.video?.viewCount ?? ''}",
                      style: textTheme.bodyMedium!.copyWith(
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),),
                IconButton(onPressed: (){
                  setState(() {
                    _isExpand = !_isExpand;
                  });
                }, icon: Icon(_isExpand ? Icons.expand_less:Icons.expand_more, size: 34, color: Colors.black,)),
              ],
            ),
            const SizedBox(height: 10.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if(_videoData?.video?.likeCount != null)Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.thumb_up_outlined,
                            color:Colors.black, size: 20,),
                          const SizedBox(width: 6.0),
                          Text(
                            _videoData?.video?.likeCount?? '',
                            style: textTheme.bodyMedium!.copyWith(color: Colors.black),
                          ),
                          const SizedBox(width: 6.0),
                          VerticalDivider(thickness:1, color: Colors.black),
                          const SizedBox(width: 6.0),
                          Icon(Icons.thumb_down_outlined,
                            color:Colors.black,size: 20,),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],),),
          if(_videoData != null)SliverList.builder(
            itemBuilder: (context, index) {
              final item =  _videoData!.videosList[index];
              return InkWell(
                onTap: (){
                  if(item.videoId != null){
                    _youtubePlayerController?.load(item.videoId!);
                  }
                },
                  child: VideoCard(video: item));
            },
            itemCount: _videoData!.videosList.length,
          )

        ],
      ),
    );
  }
}
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}