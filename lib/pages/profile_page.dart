import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kodchat/bloc/profile_bloc/user_profile_bloc.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/provider/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(alignment: Alignment.center, child: bodyUi()),
    );
  }

  Widget bodyUi() {
    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoadingUserProfileState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ErrorUserProfileState) {
          return Container(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                '${state.message}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 35,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (state is LoadedUserProfileState) {
          return userDetails(context: context, userModel: state.userModel);
        }

        return Container();
      },
    );
  }

  Widget userDetails({BuildContext context, UserModel userModel}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(100.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(userModel.imageUrl),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            child: Text(
              '${userModel.name}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            child: Text(
              '${userModel.email}',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
            ),
          ),
          SizedBox(height: 80.0),
          FlatButton(
            color: Colors.red,
            onPressed: () {
              AuthProvider.instance.logOutUser(() {});
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.70,
              height: MediaQuery.of(context).size.height * 0.05,
              child: Center(
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
