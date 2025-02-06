import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 20, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.search, color: defaultColorScheme.primary, size: 20,),
                const SizedBox(width: 20,),
                Expanded(
                  child: Text(text,
                      style: textTheme.titleMedium!.copyWith( color: defaultColorScheme.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,),
                ),
              ],
            ),
          ),
          Icon(Icons.north_west, color: defaultColorScheme.primary, size: 20,),
        ],
      ),
    );
  }
}
