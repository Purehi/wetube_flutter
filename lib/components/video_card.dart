import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/data.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
    this.onTapAvatar,
    required this.onTap
  });

  final Video video;
  final VoidCallback? onTapAvatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: InkWell(
        onTap: ()=> onTap(),
        child: Container(
          color: defaultColorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(
                children: [
                  if(video.thumbnail.isNotEmpty)AspectRatio(
                    aspectRatio: 16/9,
                    child:CachedNetworkImage(
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      imageUrl: video.thumbnail,
                      imageBuilder: (context, imageProvider){
                        return Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,),
                          ),
                        );
                      },
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: defaultColorScheme.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
                  else
                    AspectRatio(
                        aspectRatio: 16/9,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: defaultColorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),)
                    ),
                  if(video.isLive == true || video.timestampText.isNotEmpty)Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: Colors.grey.shade900),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if(video.isLive == true || video.timestampStyle == "LIVE")const SizedBox(width: 16, height: 16,child: Icon(Icons.sensors_outlined, color: Colors.redAccent,size: 16,)),
                            if(video.isLive == true || video.timestampStyle == "LIVE")const SizedBox(width: 4,),
                            if(video.timestampText == "SHORTS")const SizedBox(width: 16, height: 16, child: Icon(Icons.local_fire_department_rounded, color: Colors.white,size: 16,)),
                            Text(video.timestampText, style: textTheme.labelSmall?.copyWith(fontSize:10, color: video.timestampStyle == "LIVE" ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold), maxLines: 1,)
                          ],),
                      ))
                ],
              ),
              // Title, avtar, meta
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: Axis.horizontal,
                  children: [
                    // owner
                    if(video.avatar.isNotEmpty)InkWell(
                      onTap: onTapAvatar,
                      child: CachedNetworkImage(
                        memCacheWidth: screenWidth.toInt(),
                        imageUrl: video.avatar,
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
                          child: const Icon(Icons.error, color: Colors.red,size: 40.0),
                        ),
                      ),
                    ),
                    Expanded(child:  Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      direction: Axis.vertical,
                      children: [
                        // title
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            if(video.index != null)Text(video.index ?? "",
                              style: textTheme.titleMedium!.copyWith(
                                  color: defaultColorScheme.primary
                              ),
                            ),
                            if(video.avatar.isNotEmpty) const SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                video.title,
                                style: textTheme.titleMedium!.copyWith(
                                    color: defaultColorScheme.primary,
                                    height: 1.2
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6,),
                        // subtitle
                        if(video.index==null)
                          Flex(direction: Axis.horizontal,
                            children: [
                              if(video.avatar.isNotEmpty) const SizedBox(width: 10,),
                              Expanded(
                                child: Text(
                                  video.metadataDetails,
                                  style: textTheme.bodyMedium!.copyWith(
                                      color: defaultColorScheme.primary
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],),

                      ],
                    ),
                    ),
                    // IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






