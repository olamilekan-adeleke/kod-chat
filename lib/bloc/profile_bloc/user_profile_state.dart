part of 'user_profile_bloc.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();
}

class InitialUserProfileState extends UserProfileState {
  @override
  List<Object> get props => [];
}

class LoadingUserProfileState extends UserProfileState {
  @override
  List<Object> get props => [];
}

class LoadedUserProfileState extends UserProfileState {
  final UserModel userModel;

  LoadedUserProfileState({@required this.userModel});

  @override
  List<Object> get props => [];
}

class ErrorUserProfileState extends UserProfileState {
  final String message;

  ErrorUserProfileState({@required this.message});

  @override
  List<Object> get props => [];
}
