part of 'user_profile_bloc.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();
}

class GetUserProfileDetailsEvent extends UserProfileEvent{
  @override
  List<Object> get props => [];
}
