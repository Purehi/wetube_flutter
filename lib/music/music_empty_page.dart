import 'package:flutter/material.dart';

class MusicEmptyPage extends StatelessWidget {
  const MusicEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(children: const [
        MusicCarouselListItem(),
        SizedBox(height: 20,),
        MusicPlayListItem(),
        MusicPlayListItem(),
        MusicPlayListItem(),
        MusicPlayListItem(),
      ],),
    );
  }
}

class MusicCarouselListItem extends StatelessWidget {
  const MusicCarouselListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(context),
          const SizedBox(height: 16),
          _buildText(context),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 250,
            height: 24,
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
class MusicPlayListItem extends StatelessWidget {
  const MusicPlayListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(context),
          const SizedBox(width: 16),
          _buildText(context),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    return Container(
      height: screenWidth * 0.25,
      width: screenWidth * 0.25,
      decoration: BoxDecoration(
        color: defaultColorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final screenWidth = platformDispatcher.views.first.physicalSize.width / platformDispatcher.views.first.devicePixelRatio;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.4,
            height: 24,
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: screenWidth * 0.35,
            height: 24,
            decoration: BoxDecoration(
              color: defaultColorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}