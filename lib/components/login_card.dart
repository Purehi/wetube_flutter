import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.backgroundPromoTitle,
    required this.backgroundPromoBody,
    required this.backgroundPromoCta
  });
  final String backgroundPromoTitle;
  final String backgroundPromoBody;
  final String backgroundPromoCta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultColorScheme = Theme.of(context).colorScheme;
    return Container(
      color: defaultColorScheme.surface,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.subscriptions_rounded, size: 100, color: defaultColorScheme.onPrimary,),
              Text(backgroundPromoTitle, style: textTheme.headlineSmall?.copyWith(
                  color: defaultColorScheme.primary
              ),),
              Text(backgroundPromoBody, style: textTheme.bodyMedium?.copyWith(
                  color: defaultColorScheme.secondary
              ),),
              SizedBox(height: 24,),
              InkWell(
                onTap:() async{
                  final appId = 'free.mor.mordo.do';
                  final url = Uri.parse("market://details?id=$appId");
                  launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xff42C83C)
                  ),
                  child: Text(
                    backgroundPromoCta,
                    style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          IconButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close_rounded , color: defaultColorScheme.primary,)),
        ],
      ),
    );
  }
}




