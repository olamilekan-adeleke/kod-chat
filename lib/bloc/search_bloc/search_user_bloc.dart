import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/services/database_service.dart';

part 'search_user_event.dart';
part 'search_user_state.dart';

class SearchUserBloc extends Bloc<SearchUserEvent, SearchUserState> {
  SearchUserBloc() : super(InitialSearchUserState());

  @override
  Stream<SearchUserState> mapEventToState(
    SearchUserEvent event,
  ) async* {
    if (event is GetSearchedUserEvent) {
      try {
        yield LoadingSearchUserState();
        List<UserModel> users =
            await DatabaseService.instance.searchUserByKeyWord(event.query);

        yield LoadedSearchUserState(users: users);
      } catch (e) {
        yield ErrorSearchUserState(message: e.toString());
      }
      print('gggg');
    }
  }
}
