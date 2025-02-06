import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';

class SportsCard extends StatelessWidget{
  const SportsCard({
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
  Widget _buildNarrowLayout(BuildContext context){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16/9,
                child:CachedNetworkImage(
                  imageUrl: video.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: defaultColorScheme.onPrimaryContainer,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black12,
                    child: const Icon(Icons.error, color: Colors.red,size: 20),
                  ),
                ),
              ),
              if(video.timestampText.isNotEmpty)Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2),color: Colors.grey.shade900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if(video.timestampStyle == "LIVE")SizedBox(width: 10, height: 10,child: Icon(Icons.sensors, color: Colors.redAccent,size: 10,)),
                        if(video.timestampStyle == "LIVE")const SizedBox(width: 4,),
                        Text(video.timestampText, style: textTheme.labelSmall!.copyWith(
                            color: Colors.white
                        ), maxLines: 1,)
                      ],),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(video.avatar.isNotEmpty)InkWell(
                  onTap: onTapAvatar,
                  child: CachedNetworkImage(
                    imageUrl: video.avatar,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(color: Colors.black12),
                  ),
                ),
                // if(widget.video.avatar.isNotEmpty)const SizedBox(width: 5.0,),
                Expanded(child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // title
                    Row(
                      children: [
                        if(video.index != null)Text(video.index ?? "",
                          style: textTheme.titleMedium!,
                          textScaler: MediaQuery.textScalerOf(context),
                        ),
                        if(video.index != null || video.avatar.isNotEmpty)const SizedBox(width: 10,),
                        Expanded(
                          child: Text(
                            video.title,
                            style: textTheme.titleMedium!.copyWith(
                                height: 1.2,
                                color: defaultColorScheme.primary
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            textScaler: MediaQuery.textScalerOf(context),
                          ),
                        ),
                      ],
                    ),
                    // subtitle
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        video.metadataDetails,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: defaultColorScheme.onPrimary
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        textScaler: MediaQuery.textScalerOf(context),
                      ),
                    ),
                  ],
                ),),
                // IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))
              ],
            ),
          ),
        ],),
    );
  }
  Widget _buildWideLayout(BuildContext context){
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2,
                child:CachedNetworkImage(
                  imageUrl: video.thumbnail,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: defaultColorScheme.onPrimaryContainer,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.black12,
                    child: const Icon(Icons.error, color: Colors.red,size: 20),
                  ),
                ) ,
              ),
              if(video.timestampText.isNotEmpty)Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),color: Colors.grey.shade900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if(video.timestampStyle == "LIVE")const SizedBox(width: 10, height: 10,child: Icon(Icons.sensors, color: Colors.redAccent,size: 10,)),
                        if(video.timestampStyle == "LIVE")const SizedBox(width: 4,),
                        Text(video.timestampText, style: textTheme.bodySmall?.copyWith(
                            color: Colors.white
                        ), maxLines: 1,)
                      ],),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(video.avatar.isNotEmpty)InkWell(
                  onTap: onTapAvatar,
                  child: CachedNetworkImage(
                    imageUrl: video.avatar,
                    imageBuilder: (context, imageProvider) => Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(color: Colors.black12),
                  ),
                ),
                // if(widget.video.avatar.isNotEmpty)const SizedBox(width: 5.0,),
                Expanded(child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // title
                    Row(
                      children: [
                        if(video.index != null)Text(video.index ?? "",
                          style: textTheme.headlineSmall!,
                          textScaler: MediaQuery.textScalerOf(context),
                        ),
                        if(video.index != null || video.avatar.isNotEmpty)const SizedBox(width: 10,),
                        Expanded(
                          child: Text(
                            video.title,
                            style: textTheme.headlineMedium!.copyWith(
                                height: 1.2,
                                color: defaultColorScheme.primary
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            textScaler: MediaQuery.textScalerOf(context),
                          ),
                        ),
                      ],
                    ),
                    // subtitle
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        video.metadataDetails,
                        style: textTheme.titleMedium!.copyWith(
                            color: defaultColorScheme.onPrimary
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        textScaler: MediaQuery.textScalerOf(context),
                      ),
                    ),
                  ],
                ),),
                // IconButton(onPressed: (){}, icon: const Icon(Icons.more_vert))
              ],
            ),
          ),
        ],),
    );
  }
}
