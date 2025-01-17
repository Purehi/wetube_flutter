import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_data_api/models/video.dart';

class VideoCard extends StatefulWidget{
  const VideoCard({
    super.key,
    required this.video,
    this.onTapAvatar
  });
  final Video video;
  final VoidCallback? onTapAvatar;

  @override
  State<VideoCard> createState() => _VideoCardState();
}
class _VideoCardState extends State<VideoCard> {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              if(widget.video.thumbnails?.last.url != null)
                AspectRatio(
                aspectRatio: 16/9,
                child:CachedNetworkImage(
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  imageUrl: widget.video.thumbnails!.last.url!,
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
              )
              else
                AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),)
              ),
              if(widget.video.duration != null)Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: Colors.grey.shade900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(widget.video.duration!, style: textTheme.labelSmall!.copyWith(fontSize:10, color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1,)
                      ],),
                  ))
            ],
          ),
          // Title, avtar, meta
          if(widget.video.title != null)Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              widget.video.title!,
              style: textTheme.titleMedium?.copyWith(
                  color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(
              bottom: 10
            ),
            child: Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.horizontal,
              children: [
                // owner
                if(widget.video.channelName != null)Expanded(child:  Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: Axis.vertical,
                  children: [
                    // title
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            widget.video.channelName!,
                            style: textTheme.titleMedium!.copyWith(
                                color: Colors.grey,
                                height: 1.2
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
                ),
                // IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))
              ],
            ),
          ),
        ],
      ),
    );
  }
}