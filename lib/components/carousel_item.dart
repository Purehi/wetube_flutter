import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';
import '../model/youtube_link_manager.dart';

class CarouselItem extends StatelessWidget{
  const CarouselItem({
    super.key,
    required this.video,
    this.onTapAvatar,
    required this.onTap,
  });
  final Video video;
  final VoidCallback? onTapAvatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout(context);
        } else {
          return _buildNarrowLayout(context);
        }
      },
    );
  }
  Widget _buildNarrowLayout(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(video.thumbnail.isNotEmpty)AspectRatio(
              aspectRatio: 16/9,
              child:CachedNetworkImage(
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                imageUrl: video.thumbnail,
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: defaultColorScheme.onPrimaryContainer,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(
                top: 10.0
            ),
            child: Text(video.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium!.copyWith(
                  color: defaultColorScheme.primary,
                  height: 1.2
              ),
              textScaler: MediaQuery.textScalerOf(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 10.0),
            child: Text(video.metadataDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium!.copyWith(color: defaultColorScheme.onPrimary),),
          ),
        ],
      ),
    );
  }
  Widget _buildWideLayout(BuildContext context) {
    if(video.videoUrl == null){
      YoutubeLinkManager.shared.getYouTubeURL(video);
    }
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTapAvatar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.15,
            imageUrl: video.thumbnail,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(value: downloadProgress.progress))),
            errorWidget: (context, url, error) => const Icon(Icons.error),),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(top: 10),
              child: Text(video.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineMedium!.copyWith(color: defaultColorScheme.primary,),
                textScaler: MediaQuery.textScalerOf(context),
              )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 10.0),
            child: Text(video.metadataDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium!.copyWith(color: defaultColorScheme.onPrimary,
                  fontSize: 16),),
          ),
        ],
      ),
    );
  }
}
