import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/services/database_service.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(InitialUserProfileState());

  @override
  Stream<UserProfileState> mapEventToState(
    UserProfileEvent event,
  ) async* {
    if (event is GetUserProfileDetailsEvent) {
      try {
        yield LoadingUserProfileState();
        UserModel user = await DatabaseService.instance.getUserDetails();
        yield LoadedUserProfileState(userModel: user);
      } catch (e) {
        yield ErrorUserProfileState(message: e.toString());
      }
    }
  }
}
