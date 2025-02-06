import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:you_tube/model/data.dart';
class PlaylistTableCard extends StatefulWidget {
  const PlaylistTableCard({super.key,
    required this.title,
    required this.tables,
    required this.onTap});
  final String title;
  final List<AddToPlaylistRenderer> tables;
  final Function(AddToPlaylistRenderer add) onTap;

  @override
  State<PlaylistTableCard> createState() => _PlaylistTableCardState();
}

class _PlaylistTableCardState extends State<PlaylistTableCard> {
  @override
  Widget build(BuildContext context){
    return MediaQuery(
      data: MediaQuery.of(context).scale(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildNarrowLayout();
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
    final size = MediaQuery.of(context).size;
    final height = size.width * 9 / 16;

    return Container(
      color: defaultColorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(widget.title, style: textTheme.headlineSmall?.copyWith(
                    color: defaultColorScheme.primary
                ),),
                Spacer(),
                IconButton(onPressed: (){
                  Navigator.of(context).pop();
                }, icon: Icon(Icons.close_rounded, color: defaultColorScheme.primary,))
              ],
            ),
          ),
          Divider(color: defaultColorScheme.onPrimaryContainer,),
          SizedBox(
            height: size.height - kBottomNavigationBarHeight - height,
            child: ListView.builder(itemBuilder: (context, index){
              final add = widget.tables[index];
              return ListTile(
                title: Text(add.title, style: textTheme.titleMedium?.copyWith(
                  color: defaultColorScheme.primary
                ),),
                leading: Icon(add.containsSelectedVideos == 'ALL' ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: defaultColorScheme.primary,),
                onTap: (){
                  if(add.containsSelectedVideos == 'ALL'){
                    setState(() {
                      add.containsSelectedVideos = 'NONE';
                    });
                  }else{
                    setState(() {
                      add.containsSelectedVideos = 'ALL';
                    });
                  }
                  widget.onTap(add);
                },
              );},
              itemCount: widget.tables.length,
            ),
          ),
        ],
      ),
    );
  }
}
