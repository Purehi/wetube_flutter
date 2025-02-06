
import 'package:flutter/material.dart';

class EmptyPodcastPage extends StatelessWidget {
  const EmptyPodcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    return Container(
      color: defaultColorScheme.surface,
      child: GridView.builder(shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // number of items in each row
            mainAxisSpacing: 12.0, // spacing between rows
            crossAxisSpacing: 12.0, // spacing between columns
          ), // padding around the grid
          itemCount: 12, itemBuilder: (context, index){
        return EmptyPodcastListItem();
      }),
    );
  }
}
class EmptyPodcastListItem extends StatelessWidget {
  const EmptyPodcastListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(context),
        const SizedBox(height: 16),
        _buildText(context),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: defaultColorScheme.onPrimaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 20,
          decoration: BoxDecoration(
            color: defaultColorScheme.onPrimaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12,),
        Padding(
          padding: const EdgeInsets.only(right: 60.0),
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}