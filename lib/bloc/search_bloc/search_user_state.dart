part of 'search_user_bloc.dart';

abstract class SearchUserState extends Equatable {
  const SearchUserState();
}

class InitialSearchUserState extends SearchUserState {
  @override
  List<Object> get props => [];
}

class LoadingSearchUserState extends SearchUserState {
  @override
  List<Object> get props => [];
}

class LoadedSearchUserState extends SearchUserState {
  final List<UserModel> users;

  LoadedSearchUserState({@required this.users});

  @override
  List<Object> get props => [];
}

class ErrorSearchUserState extends SearchUserState {
  final String message;

  ErrorSearchUserState({@required this.message});

  @override
  List<Object> get props => [];
}
