part of 'search_user_bloc.dart';

abstract class SearchUserEvent extends Equatable {
  const SearchUserEvent();
}

class GetSearchedUserEvent extends SearchUserEvent{
  final String query;

  GetSearchedUserEvent({@required this.query});

  @override
  List<Object> get props => [];
}