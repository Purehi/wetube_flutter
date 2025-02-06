import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:you_tube/model/data.dart';
import 'package:you_tube/pages/playlist_page.dart';


class PlaylistCard extends StatelessWidget {
  const PlaylistCard({super.key, required this.musicVideo});
  final Video musicVideo;

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
        onTap: (){
          if(musicVideo.browseId != null){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PlaylistPage(video: musicVideo,)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(musicVideo.thumbnail),
                      fit: BoxFit.cover
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              SizedBox(
                width: MediaQuery.of(context).size.height * 0.15,
                child: Text(musicVideo.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: defaultColorScheme.primary,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.height * 0.15,
                child: Text(musicVideo.metadataDetails,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: defaultColorScheme.onPrimary,
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}


