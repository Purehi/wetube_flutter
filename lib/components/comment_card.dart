import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/data.dart';

class CommentCard extends StatefulWidget{
  const CommentCard({super.key,
    required this.renderer,
    required this.onTapLike,
    required this.onTapDislike});
  final CommentThreadRenderer renderer;
  final Function(bool) onTapLike;
  final Function(bool) onTapDislike;
  @override
  CommentCardState createState() => CommentCardState();
}
class CommentCardState extends State<CommentCard>{

  bool _like = false, _dislike = false;
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:10),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: widget.renderer.authorThumbnail,
            imageBuilder: (context, imageProvider) => Container(
              height: 30.0,
              width: 30.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
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
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black12,
              child: const Icon(Icons.error, color: Colors.red,size: 30.0),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.renderer.authorText}·${widget.renderer.publishedTimeText}', style: textTheme.bodyMedium?.copyWith(color: defaultColorScheme.onPrimary,),),
                Text(widget.renderer.contentText, style: textTheme.titleSmall?.copyWith(color: defaultColorScheme.primary,), maxLines: 2,),
                Row(children: [
                  InkWell(
                      onTap: (){
                        widget.onTapLike(_like);
                      },
                      child: Icon(_like ? Icons.thumb_up : Icons.thumb_up_outlined, size: 16, color: _like ? Color(0xff42C83C) : defaultColorScheme.primary,)),
                  const SizedBox(width: 5,),
                  Text(
                    widget.renderer.likeCountLiked,
                    style: textTheme.bodyMedium?.copyWith(color: defaultColorScheme.primary),
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                      onTap: (){
                        widget.onTapLike(_dislike);
                      },
                      child: Icon(_dislike ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined, size: 16, color:_dislike ? Color(0xff42C83C) : defaultColorScheme.primary)),
                ],)
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _buildWideLayout(){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:20),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(widget.renderer.authorThumbnail),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.renderer.authorText}·${widget.renderer.publishedTimeText}', style: textTheme.titleLarge!.copyWith(color: defaultColorScheme.onPrimary,),),
                Text(widget.renderer.contentText, style: textTheme.headlineMedium!.copyWith(color: defaultColorScheme.primary,), maxLines: 2,),
                Row(children: [
                  const Icon(Icons.thumb_up_outlined, size: 30,),
                  const SizedBox(width: 10,),
                  Text(
                    widget.renderer.likeCountLiked,
                    style: textTheme.titleLarge!.copyWith(color: defaultColorScheme.primary),
                  ),
                  const SizedBox(width: 20,),
                  const Icon(Icons.thumb_down_alt_outlined, size: 30,),
                ],)
              ],
            ),
          )
        ],
      ),
    );
  }
}