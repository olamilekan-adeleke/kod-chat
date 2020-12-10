import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kodchat/bloc/profile_bloc/user_profile_bloc.dart';
import 'package:kodchat/bloc/search_bloc/search_user_bloc.dart';

List<BlocProvider> blocList({@required BuildContext context}) {
  return <BlocProvider>[
    BlocProvider<UserProfileBloc>(
      create: (BuildContext context) => UserProfileBloc()
        ..add(
          GetUserProfileDetailsEvent(),
        ),
    ),
    BlocProvider<SearchUserBloc>(
      create: (BuildContext context) => SearchUserBloc(),
    ),
  ];
}
