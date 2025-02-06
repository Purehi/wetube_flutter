import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';
class PlaylistItem extends StatelessWidget {
  const PlaylistItem({super.key, required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(
          height: screenWidth * 0.25,
          width: screenWidth * 0.25,
          child: CachedNetworkImage(
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageUrl: video.thumbnail,
            imageBuilder: (context, imageProvider) => Container(
              height: screenWidth * 0.25,
              width: screenWidth * 0.25,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                color: Colors.transparent,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, downloadProgress) => Container(
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(Icons.error, color: Colors.grey),
          ),),
        ),
          const SizedBox(width: 10,),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(video.title, style: textTheme.titleMedium?.copyWith(
                  color: defaultColorScheme.primary,
                  fontWeight: FontWeight.bold
              ),maxLines: 2,overflow: TextOverflow.ellipsis,),
              if(video.timestampText.isNotEmpty)Text(video.timestampText, style: textTheme.bodyMedium?.copyWith(
                  color: defaultColorScheme.secondary,
              ),maxLines: 2,),
              if(video.metadataDetails.isNotEmpty)Text(video.metadataDetails.replaceAll('YouTube', ''), style: textTheme.bodyMedium?.copyWith(color: defaultColorScheme.onPrimary),maxLines: 2,),
            ],
          )),
        ],
      ),
    );
  }
}
