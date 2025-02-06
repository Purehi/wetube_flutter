import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/data.dart';
import '../components/playlist_item_card.dart';


class PlaylistSubPage extends StatefulWidget {
  const PlaylistSubPage({super.key,
    required this.info,
    required this.onTap,
    required this.contentHeight,
   });
  final PlaylistInfo info;
  final Function(int) onTap;
  final double contentHeight;

  @override
  State<PlaylistSubPage> createState() => _PlaylistSubPageState();
}
class _PlaylistSubPageState extends State<PlaylistSubPage>{

  late List<Video> _videos = [];
  int _currentIndex = 0;

  @override
  void initState() {
    _videos = widget.info.videos;
    _currentIndex = widget.info.currentIndex;
    super.initState();
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
      height: widget.contentHeight,
      decoration: BoxDecoration(
        color: defaultColorScheme.surface,
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Builder(builder: (context){
        if(_videos.isNotEmpty){
          return Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 12.0,),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.info.title,
                                      style: textTheme.titleMedium?.copyWith(
                                          color: defaultColorScheme.primary,
                                          fontWeight: FontWeight.bold
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              '${_currentIndex + 1}/${widget.info.videos.length}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: defaultColorScheme.onPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              widget.info.owner.replaceAll('YouTube', ''),
                              style: textTheme.labelMedium?.copyWith(
                                  color: defaultColorScheme.onPrimary,
                                  fontWeight: FontWeight.bold
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  },
                      icon: Icon(Icons.close_outlined, color: defaultColorScheme.primary,)),
                ],),
              Divider(height: 1.0,color: defaultColorScheme.onPrimaryContainer,),
              Expanded(
                child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final item = _videos[index];
                      if(index == _currentIndex){
                        return Container(
                          color: defaultColorScheme.onPrimaryContainer,
                          child: PlaylistItemCard(video: item, onTap: () {
                            setState(() {
                              _currentIndex = index;
                            });
                            widget.onTap(index);
                          },),);
                      }
                      return PlaylistItemCard(video: item, onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        widget.onTap(index);
                      },);
                    },
                    separatorBuilder: (context, position) {
                      return const SizedBox.shrink();
                    },
                    itemCount: _videos.length + 1),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

}
