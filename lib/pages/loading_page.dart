import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
          shrinkWrap: true,
          children: const [
            CardListItem(),
            CardListItem(),
            CardListItem(),
            CardListItem(),
          ],
      ),
    );
  }
}

class CardListItem extends StatelessWidget {
  const CardListItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(context),
        _buildText(context),
        SizedBox(height: 16.0,)
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