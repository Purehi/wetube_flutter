import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/components/comment_card.dart';
import 'package:you_tube/model/api_request.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:you_tube/model/data.dart';
import 'package:you_tube/model/youtube_client.dart';
import 'package:you_tube/pages/loading_page.dart';

import '../components/login_card.dart';


class CommentPage extends StatefulWidget {
  final Video video;
  final double contentHeight;
  const CommentPage({
    super.key,
    required this.video,
    required this.contentHeight});

  @override
  State<CommentPage> createState() => _CommentPageState();
}
class _CommentPageState extends State<CommentPage>{

  final List<CommentThreadRenderer> _comments = [];
   String? _token;
   final _videoKey = UniqueKey();
   bool _isLoadingData = false;
   final txt = TextEditingController();
   String? _placeholderText;
   String? _authorThumbnail;
   String? _createCommentParams;
   String? _authorText;

  @override
  void initState() {
    super.initState();
    final headerRenderer = widget.video.headerRenderer;
    _placeholderText = headerRenderer?.placeholderText;
    _authorThumbnail = headerRenderer?.authorThumbnail;
    _createCommentParams = headerRenderer?.createCommentParams;
    _authorText = headerRenderer?.authorText;
    _token = headerRenderer?.commentToken ?? widget.video.commentContinuation;

    if(headerRenderer != null && headerRenderer.comments.isNotEmpty){
      _comments.addAll(headerRenderer.comments);
    }else{
      if(_token != null && _token!.isNotEmpty){
        _fetchComments(_token!);
      }
    }
  }

   @override
   Widget build(BuildContext context){

    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: _buildNarrowLayout(),
    );
  }
   Widget _buildNarrowLayout(){
     final defaultColorScheme = Theme.of(context).colorScheme;
     final textTheme = Theme.of(context).textTheme;
    return Container(
      color: defaultColorScheme.surface,
      height: widget.contentHeight,
      child: Builder(builder: (context){
        if(_comments.isNotEmpty){
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: defaultColorScheme.surface,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 12,),
                        Text(widget.video.headerRenderer?.headerText ?? 'Comments', style:
                        textTheme.titleMedium?.copyWith(
                            color: defaultColorScheme.primary,
                            fontWeight: FontWeight.bold
                        ),),
                        SizedBox(width: 4,),
                        Text(widget.video.headerRenderer?.commentCount ?? '0', style:
                        textTheme.bodyMedium?.copyWith(
                            color: Colors.grey
                        ),),
                        Spacer(),
                        IconButton(onPressed: (){
                          Navigator.of(context).pop();
                        }, icon: Icon(Icons.close, color: defaultColorScheme.primary,))
                      ],
                    ),
                    Divider(height: 1.0,color: defaultColorScheme.onPrimaryContainer,)
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: _comments.isEmpty ? 1 : _comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    final comment = _comments[index];
                    if(index == _comments.length - 5){
                      if(_token != null && _token!.isNotEmpty){
                        _fetchComments(_token!);
                      }
                    }
                    if(index == _comments.length - 1 && _token != null && _token!.isNotEmpty){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CommentCard(renderer: comment,key: _videoKey, onTapLike: (like){
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: LoginCard(
                                    backgroundPromoTitle:'Want to perform action for this comment.',
                                    backgroundPromoBody: 'Get app from google play store.',
                                    backgroundPromoCta:'Get it',
                                  ),
                                ));
                          }, onTapDislike: (dislike){
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: LoginCard(
                                    backgroundPromoTitle:'Want to perform action for this comment.',
                                    backgroundPromoBody: 'Get app from google play store.',
                                    backgroundPromoCta:'Get it',
                                  ),
                                ));
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
                    return CommentCard(renderer: comment, onTapLike: (like){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: LoginCard(
                              backgroundPromoTitle:'Want to perform action for this comment.',
                              backgroundPromoBody: 'Get app from google play store.',
                              backgroundPromoCta:'Get it',
                            ),
                          ));
                    }, onTapDislike: (dislike){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: LoginCard(
                              backgroundPromoTitle:'Want to perform action for this comment.',
                              backgroundPromoBody: 'Get app from google play store.',
                              backgroundPromoCta:'Get it',
                            ),
                          ));
                    },);
                  },
                  separatorBuilder: (BuildContext context, int position){
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      Divider(height: 1.0, color: defaultColorScheme.onPrimaryContainer,),
                      Container(
                        height: kToolbarHeight,
                        padding: EdgeInsets.only(left: 12.0).copyWith(
                            top: 12.0
                        ),
                        decoration: BoxDecoration(
                          color: defaultColorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            if(_authorThumbnail != null)InkWell(
                              child: CachedNetworkImage(
                                imageUrl: _authorThumbnail!,
                                imageBuilder: (context, imageProvider) => Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  height: 30.0,
                                  width: 30.0,
                                  decoration: BoxDecoration(
                                    color: defaultColorScheme.onPrimaryContainer,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.black12,
                                  child: Icon(Icons.error, color: defaultColorScheme.onPrimaryContainer,size: 30.0),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0,),
                            Expanded(
                              child: TextField(
                                style: textTheme.titleMedium?.copyWith(color:defaultColorScheme.primary),
                                controller: txt,
                                onSubmitted: (query){
                                  txt.text = query;
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: LoginCard(
                                          backgroundPromoTitle:'Want to perform action for this comment.',
                                          backgroundPromoBody: 'Get app from google play store.',
                                          backgroundPromoCta:'Get it',
                                        ),
                                      ));

                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: defaultColorScheme.onPrimaryContainer,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                  /* -- Text and Icon -- */
                                  hintText: _placeholderText ?? 'Add a comment',
                                  hintStyle: textTheme.titleMedium?.copyWith(color:defaultColorScheme.onPrimary),// TextStyle// Icon
                                  /* -- Border Styling -- */
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    borderSide: const BorderSide(
                                      width: 2.0,
                                      color: Colors.transparent,
                                    ), // BorderSide
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                    borderSide: const BorderSide(
                                      width: 2.0,
                                      color: Colors.transparent,
                                    ), // BorderSide
                                  ), // OutlineInputBorder
                                ), // InputDecoration
                              ),
                            ),
                            IconButton(onPressed: (){
                              if(txt.text.isNotEmpty){
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: LoginCard(
                                        backgroundPromoTitle: 'Want to post comment to this video?',
                                        backgroundPromoBody: 'Get app from google play store.',
                                        backgroundPromoCta: 'Get it',
                                      ),
                                    ));
                              }

                            }, icon: Icon(Icons.send_rounded, color: defaultColorScheme.primary,)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        }
        return Column(
          children: [
            Container(
              height: kToolbarHeight,
              decoration: BoxDecoration(
                color: defaultColorScheme.surface,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 12,),
                      Text(widget.video.headerRenderer?.headerText ?? 'Comments', style:
                      textTheme.titleMedium?.copyWith(
                          color: defaultColorScheme.primary,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(width: 4,),
                      Text(widget.video.headerRenderer?.commentCount ?? '0', style:
                      textTheme.bodyMedium?.copyWith(
                          color: Colors.grey
                      ),),
                      Spacer(),
                      IconButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, icon: Icon(Icons.close, color: defaultColorScheme.primary,))
                    ],
                  ),
                  Divider(height: 1.0,color: defaultColorScheme.onPrimaryContainer,)
                ],
              ),
            ),
            Expanded(child: const LoadingPage()),
          ],
        );
      })
    );
   }

   Future<void> _fetchComments(String continuation) async {
     if(_isLoadingData)return;
     _isLoadingData = true;
      Map<String, dynamic> body = {
      "context": youtubeContext['context'],
      "continuation": continuation,
    };
     final uri = Uri.parse('$host/next?key=$key&prettyPrint=false');
     http.Response response = await http.post(uri, body: json.encode(body));
     _isLoadingData = false;
     if (response.statusCode == 200) {
       //开启异步线程
       final result = await compute(_parseData, response.body);
       final comments = result['comments'];
       _token = result['nextToken'];
       _placeholderText = result['placeholderText'];
       _authorThumbnail = result['authorThumbnail'];
       _createCommentParams = result['createCommentParams'];
       _authorText = result['authorText'];
       widget.video.headerRenderer?.commentToken = _token;
       final headerRenderer = widget.video.headerRenderer;
       headerRenderer?.authorText = _authorText;
       headerRenderer?.createCommentParams = _createCommentParams;
       headerRenderer?.placeholderText = _placeholderText;
       headerRenderer?.authorThumbnail = _authorThumbnail;

       if(comments != null && comments.isNotEmpty){

         widget.video.headerRenderer?.comments.addAll(comments);
         if(widget.video.headerRenderer != null && widget.video.headerRenderer!.teasers.length == 1){
           final CommentThreadRenderer first = comments.first;
           final teaser = TeaserRenderer(avatar: first.authorThumbnail, author: first.authorText, content: first.contentText);
           widget.video.headerRenderer!.teasers.add(teaser);
         }
         setState(() {
           _comments.addAll(comments);
         });
       }
     }

   }
   static Map<String, dynamic> _parseData(String responseBody) {
     final result = jsonDecode(responseBody);
     final comments = parseComments(result);
     final nextToken = parseWebCommentsNextToken(result);
     final frameworkUpdates = result?['frameworkUpdates'];
     final entityBatchUpdate = frameworkUpdates?['entityBatchUpdate'];
     final List<dynamic>? mutations = entityBatchUpdate?['mutations'];
     String? likeAction, unlikeAction, dislikeAction, undislikeAction;
     String? placeholder;
     String? thumbnail;
     String? createCommentParams;
     String? authorText;
     for(final mutation in mutations ?? []){
       final payload = mutation?['payload'];
       final engagementToolbarSurfaceEntityPayload = payload?['engagementToolbarSurfaceEntityPayload'];
       final likeCommand = engagementToolbarSurfaceEntityPayload?['likeCommand'];
       likeAction ??= _parseAction(likeCommand);

       final unlikeCommand = engagementToolbarSurfaceEntityPayload?['unlikeCommand'];
       unlikeAction ??= _parseAction(unlikeCommand);

       final dislikeCommand = engagementToolbarSurfaceEntityPayload?['dislikeCommand'];
       dislikeAction ??= _parseAction(dislikeCommand);

       final undislikeCommand = engagementToolbarSurfaceEntityPayload?['undislikeCommand'];
       undislikeAction ??= _parseAction(undislikeCommand);

     }
     final List<dynamic>? onResponseReceivedEndpoints = result?['onResponseReceivedEndpoints'];
     for(final onResponseReceivedEndpoint in onResponseReceivedEndpoints ?? []){
       final reloadContinuationItemsCommand = onResponseReceivedEndpoint?['reloadContinuationItemsCommand'];
       final List<dynamic>? continuationItems = reloadContinuationItemsCommand?['continuationItems'];
       for(final continuationItem in continuationItems ?? []){
         final commentsHeaderRenderer = continuationItem?['commentsHeaderRenderer'];

         final createRenderer = commentsHeaderRenderer?['createRenderer'];
         final commentSimpleboxRenderer = createRenderer?['commentSimpleboxRenderer'];
         final authorThumbnail = commentSimpleboxRenderer?['authorThumbnail'];
         final List<dynamic>? thumbnails = authorThumbnail?['thumbnails'];
         thumbnail ??= thumbnails?.firstOrNull['url'];
         final accessibility = authorThumbnail?['accessibility'];
         final accessibilityData = accessibility?['accessibilityData'];
         final label = accessibilityData?['label'];
         authorText ??= label;

         final placeholderText = commentSimpleboxRenderer?['placeholderText'];
         placeholder ??= parseText(placeholderText?['runs']);

         final submitButton = commentSimpleboxRenderer?['submitButton'];
         final buttonRenderer = submitButton?['buttonRenderer'];
         final serviceEndpoint = buttonRenderer?['serviceEndpoint'];
         final channelCreationServiceEndpoint = serviceEndpoint?['channelCreationServiceEndpoint'];
         final zeroStepChannelCreationParams = channelCreationServiceEndpoint?['zeroStepChannelCreationParams'];
         final zeroStepCreateCommentParams = zeroStepChannelCreationParams?['zeroStepCreateCommentParams'];
         createCommentParams ??= zeroStepCreateCommentParams?['createCommentParams'];
       }
     }
     return {'comments' : comments,
       'nextToken':nextToken,
       'likeAction': likeAction,
       'unlikeAction':unlikeAction,
       'dislikeAction': dislikeAction,
       'undislikeAction': undislikeAction,
       'placeholderText': placeholder,
       'authorThumbnail':thumbnail,
       'createCommentParams': createCommentParams,
       'authorText':authorText
     };

   }

   static String? _parseAction(dynamic result){
     final innertubeCommand = result?['innertubeCommand'];
     final performCommentActionEndpoint = innertubeCommand?['performCommentActionEndpoint'];
     final action = performCommentActionEndpoint?['action'];
     return action;
   }
}