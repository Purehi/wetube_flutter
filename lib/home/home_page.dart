import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:wetube_flutter/home/home_sub_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DefaultTabController(
      length: 4 ,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                  scrolledUnderElevation:0.0,
                  shadowColor: Colors.transparent,
                  elevation: 0.0,
                  toolbarHeight: kToolbarHeight * 1.5,
                  backgroundColor: Colors.white,
                  excludeHeaderSemantics: true, // question having 0 here
                  title: Row(
                    spacing: 6,
                    children: [
                      Image.asset('assets/images/logo.png', width: 30, height: 30,),
                      Text('WeTube', style: textTheme.headlineSmall!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                  bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(0),
                      child: TabBar(
                        padding: EdgeInsets.zero,
                        tabAlignment: TabAlignment.start,
                        labelColor: Color(0xff42C83C),
                        indicatorSize: TabBarIndicatorSize.label,
                        unselectedLabelColor:Colors.grey,
                        unselectedLabelStyle: textTheme.titleMedium,
                        labelStyle: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold
                        ),
                        indicatorColor: Colors.transparent,
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Trending', height: 34,),
                          Tab(text: 'Music', height: 34,),
                          Tab(text: 'Gaming', height: 34,),
                          Tab(text: 'Movie', height: 34,),
                        ],
                      )
                  ) ),
            ];
          },
          body: TabBarView(
              children: [
                HomeSubPage(index: 0),
                HomeSubPage(index: 1),
                HomeSubPage(index: 2),
                HomeSubPage(index: 3),
              ])
          ),
      ),
    );
  }
}
