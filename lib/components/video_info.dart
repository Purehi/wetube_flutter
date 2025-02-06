import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/components/login_card.dart';
import 'package:you_tube/model/data.dart';
import 'package:share_plus/share_plus.dart';

class VideoInfo extends StatefulWidget {
  const VideoInfo({
    super.key,
    required this.video,
    this.likeCount,
    this.saveText,
    this.onTapAvatar,
    this.onTapPIP
  });

  final Video? video;
  final String? likeCount;
  final String? saveText;
  final VoidCallback? onTapAvatar;
  final VoidCallback? onTapPIP;

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}
class _VideoInfoState extends State<VideoInfo> with TickerProviderStateMixin {

  final bool _isSaved = false;
  bool _isExpand = false;
  bool _isLike = false;
  bool _isDislike = false;
  bool _isSubscribed = false;
  final bool _isClicked = false;

  @override
  void initState() {
    _isLike = widget.video?.likeStatus == 'LIKE';
    _isSubscribed =  widget.video?.isSubscribed ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildNarrowLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }
  Widget _buildNarrowLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: defaultColorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 12.0,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.video!.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: defaultColorScheme.primary,
                      ),
                      maxLines: _isExpand ? null : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.video!.metadataDetails,
                      style: textTheme.bodyMedium?.copyWith(
                        color: defaultColorScheme.onPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: (){
                setState(() {
                  _isExpand = !_isExpand;
                });
              }, icon: Icon(_isExpand ? Icons.expand_less:Icons.expand_more, color: defaultColorScheme.primary,)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            SizedBox(width: 12.0,),
            if(widget.video!.avatar.isNotEmpty && widget.video?.channelName != null) InkWell(
              onTap: widget.onTapAvatar,
              child: CachedNetworkImage(
                imageUrl: widget.video!.avatar,
                imageBuilder: (context, imageProvider) => Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(color: defaultColorScheme.onPrimaryContainer),
                errorWidget: (context, url, error) => Container(
                  color: defaultColorScheme.primaryContainer,
                  child: const Icon(Icons.error, color: Colors.grey,size: 40.0),
                ),
              ),
            ),
            if(widget.video?.channelName != null)Expanded(
              // width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    TextSpan(
                      children: [
                        TextSpan(text: ' ${widget.video!.channelName}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: defaultColorScheme.primary
                        )),
                        TextSpan(
                          text: ' ${widget.video!.subscriberCount}',
                          style: textTheme.labelMedium?.copyWith(
                              color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if(widget.video?.subscribed != null || widget.video?.unsubscribed != null)InkWell(
              onTap:() async{
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: LoginCard(
                        backgroundPromoTitle: widget.video?.subscribeModalWithTitle ?? 'Want to subscribe to this channel?',
                        backgroundPromoBody: widget.video?.subscribeModalWithContent ?? 'Get app from google play store.',
                        backgroundPromoCta: widget.video?.subscribeModalWithButton ?? 'Get it.',
                      ),
                    ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: _isSubscribed ? defaultColorScheme.surface:Color(0xff42C83C),
                    border: Border.all(color: _isSubscribed ? defaultColorScheme.primary : Color(0xff42C83C))
                ),
                child: Text(
                  _isSubscribed ? widget.video?.unsubscribed
                      ?? 'Unsubscribed' : widget.video?.subscribed ?? 'Subscribed',
                  style: textTheme.bodySmall?.copyWith(color:
                  _isSubscribed ? defaultColorScheme.primary : Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(width: 12.0,),
          ],),
          const SizedBox(height: 12,),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 12.0,
              children: [
                if(widget.likeCount != null)Container(
                  margin: EdgeInsets.only(left: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: defaultColorScheme.onPrimaryContainer
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: LoginCard(
                                    backgroundPromoTitle: widget.video?.subscribeModalWithTitle ?? 'Want to subscribe to this channel?',
                                    backgroundPromoBody: widget.video?.subscribeModalWithContent ?? 'Get app from google play store.',
                                    backgroundPromoCta: widget.video?.subscribeModalWithButton ?? 'Get it',
                                  ),
                                ));
                          },
                          child: Icon(_isLike?Icons.thumb_up_rounded:Icons.thumb_up_outlined,
                            color:_isLike ? const Color(0xff42C83C):defaultColorScheme.primary, size: 20,),
                        ),
                        Text(
                          widget.likeCount!,
                          style: textTheme.bodyMedium!.copyWith(color: defaultColorScheme.primary),
                        ),
                        VerticalDivider(thickness:1, color: defaultColorScheme.onSecondary),
                        InkWell(
                          onTap: (){
                            setState(() {
                              _isDislike =!_isDislike;
                            });
                          },
                          child: Icon(_isDislike?Icons.thumb_down_rounded:Icons.thumb_down_outlined,
                            color:_isDislike?const Color(0xff42C83C):defaultColorScheme.primary,),
                        ),
                      ],
                    ),
                  ),
                ),
                if(widget.video?.shareText != null)Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: defaultColorScheme.onPrimaryContainer
                  ),
                  child: InkWell(
                    onTap: widget.onTapPIP,
                    child: Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_in_picture_alt_rounded, color: defaultColorScheme.primary,),
                        Text(
                          'Popup',
                          style:textTheme.bodyMedium?.copyWith(color: defaultColorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                if(widget.video?.shareText != null)Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: defaultColorScheme.onPrimaryContainer
                  ),
                  child: InkWell(
                    onTap: (){
                      Share.shareUri(Uri.parse('https://play.google.com/store/apps/details?id=free.mor.mordo.do'));
                    },
                    child: Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, color: defaultColorScheme.primary),
                        Text(
                          widget.video!.shareText!,
                          style:textTheme.bodyMedium?.copyWith(color: defaultColorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                if(widget.saveText != null)Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  margin: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: defaultColorScheme.onPrimaryContainer
                  ),
                  child: InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: LoginCard(
                              backgroundPromoTitle: widget.video?.saveModalWithTitle ?? 'Want to watch this again later?',
                              backgroundPromoBody: widget.video?.saveModalWithContent ?? 'Get app from google play store.',
                              backgroundPromoCta: widget.video?.saveModalWithButton ?? 'Get it',
                            ),
                          ));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        if(_isClicked)SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2.0, color: Color(0xff42C83C) ,)),
                        if(!_isClicked)Icon(_isSaved ? Icons.bookmark_add_rounded:Icons.bookmark_add_outlined, color: _isSaved ? Color(0xff42C83C) : defaultColorScheme.primary,),
                        Text(
                          widget.saveText!,
                          style:textTheme.bodyMedium!.copyWith(color: defaultColorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}