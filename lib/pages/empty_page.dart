import 'package:flutter/material.dart';

class EmptyPage extends StatefulWidget {
  const EmptyPage({super.key, this.onTap, this.tips, this.hiddenButton});
  final VoidCallback? onTap;
  final String? tips;
  final bool? hiddenButton;
  @override
  State<EmptyPage> createState() => _EmptyPageState();
}

class _EmptyPageState extends State<EmptyPage> {


  final String _emptyPageTips = 'Something went wrong,please try again.';
  final String _emptyPageRetryTips = 'Retry';
  final String _emptyPageTitle = 'Oops!';

  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Container(
        height: 150, // Border width
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Image.asset('assets/images/empty_state.png', fit: BoxFit.cover,),
      ),
        Flexible(
        child: Text(
          _emptyPageTitle,
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color:defaultColorScheme.primary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
        Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            maxLines: 3,
            widget.tips ?? _emptyPageTips,
            style: textTheme.titleMedium?.copyWith(color:defaultColorScheme.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
        const SizedBox(height: 20,),
        if(widget.hiddenButton != true)InkWell(
        onTap: widget.onTap,
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 50),
          padding: const EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xffc3ef07)
          ),
          child: Text(
            _emptyPageRetryTips,
            style: textTheme.titleMedium!.copyWith(color:defaultColorScheme.primary),
          ),
        ),
      ),
        if(widget.hiddenButton != true)const SizedBox(height: 20,),
    ],);
  }

}
