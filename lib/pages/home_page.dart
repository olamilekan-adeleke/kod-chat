import 'package:flutter/material.dart';
import 'package:kodchat/pages/chat_home_page.dart';
import 'package:kodchat/pages/profile_page.dart';
import 'package:kodchat/pages/search_users_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          initialIndex: 1,
          length: 3,
          child: Column(
            children: [
              tab(context),
              body(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget tab(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: MediaQuery.of(context).size.height * 0.10,
      child: TabBar(
        labelColor: Colors.blue,
        indicatorColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        physics: BouncingScrollPhysics(),
        tabs: [
          Tab(icon: Icon(Icons.people)),
          Tab(icon: Icon(Icons.forum)),
          Tab(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget body(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          SearchUserPage(),
          ChatHomePage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
