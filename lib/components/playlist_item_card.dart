import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';


class PlaylistItemCard extends StatelessWidget{
  const PlaylistItemCard({
    super.key,
    required this.video,
    required this.onTap,
  });
  final Video video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(
            top: 12.0
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              width: screenWidth * 0.35,
              height: screenWidth * 0.35 * 9 / 16,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              imageUrl: video.thumbnail,
              imageBuilder: (context, imageProvider) => Stack(
                children: [
                  Container(
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.35 * 9 / 16,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius:  BorderRadius.circular(6),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if(video.timestampText.isNotEmpty)Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),color: Colors.black54),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if(video.timestampStyle == "LIVE")const SizedBox(width: 12, height: 12,child: Icon(Icons.sensors_outlined, color: Colors.redAccent,size: 12,)),
                            if(video.timestampStyle == "LIVE")const SizedBox(width: 4,),
                            if(video.timestampText == "SHORTS")const SizedBox(width: 12, height: 12, child: Icon(Icons.local_fire_department_rounded, color: Colors.white,size: 12,)),
                            Text(video.timestampText, style: textTheme.labelSmall?.copyWith(fontSize:8, color:video.timestampStyle == "LIVE" ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold), maxLines: 1,)
                          ],),
                      ))
                ],
              ),
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: defaultColorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),),
            const SizedBox(width: 10,),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(video.title, style: textTheme.titleMedium?.copyWith(color: defaultColorScheme.primary),maxLines: 2,overflow: TextOverflow.ellipsis,),
                if(video.metadataDetails.isNotEmpty)Text(video.metadataDetails.replaceAll('YouTube', ''), style: textTheme.labelMedium?.copyWith(color: defaultColorScheme.onPrimary),maxLines: 1,),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

