import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kodchat/bloc/search_bloc/search_user_bloc.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/pages/conversation_page.dart';
import 'package:kodchat/services/navigation_service.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage>
    with AutomaticKeepAliveClientMixin {
  List<UserModel> users = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            searchBar(context),
            blocBody(),
          ],
        ),
      ),
    );
  }

  Widget blocBody() {
    return BlocConsumer<SearchUserBloc, SearchUserState>(
      listener: (context, state) {
        if (state is LoadedSearchUserState) {
          users.addAll(state.users);
        }
      },
      builder: (context, state) {
        if (state is InitialSearchUserState) {
          return searchUserImageUi(context);
        } else if (state is LoadingSearchUserState) {
          return Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.60,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is LoadedSearchUserState) {
          if (users.isEmpty && state.users.isEmpty) {
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.60,
              child: Center(
                child: Text(
                  'Opps, No User Was Found!!',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else if (state is ErrorSearchUserState) {
          if (users.isEmpty) {
            return Text(
              '${state.message}',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
              textAlign: TextAlign.center,
            );
          } else {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.message}'),
                duration: Duration(seconds: 4),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        return bodyUi();
      },
    );
  }

  Widget bodyUi() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      itemBuilder: (_, index) {
        UserModel currentUser = users[index];
        return ListTile(
          onTap: () {
            NavigationService.instance.navigateToPage(
              MaterialPageRoute(
                builder: (context) => ConversationPage(
                  receiverImageUrl: currentUser.imageUrl,
                  receiverId: currentUser.uid,
                  receiverName: currentUser.name,
                  conversationDocId: null,
                ),
              ),
            );
          },
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(100.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(currentUser.imageUrl),
              ),
            ),
          ),
          title: Text(
            '${currentUser.name}',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
          ),
        );
      },
    );
  }

  Widget searchUserImageUi(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            width: MediaQuery.of(context).size.width * 0.60,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('asset/search.png')),
            ),
          ),
          Text(
            'Search For Other User By Username.',
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 20),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget searchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01,
        vertical: 20.0,
      ),
      child: TextFormField(
        autocorrect: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search User',
          focusColor: Colors.white,
          helperStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
          border: OutlineInputBorder(),
        ),
        onFieldSubmitted: (val) {
          print(val);
          users.clear();
          if (val.trim().length >= 1) {
            BlocProvider.of<SearchUserBloc>(context)
                .add(GetSearchedUserEvent(query: val.trim()));
          } else {
//            BlocProvider.of<SearchUserBloc>(context)
//                .add(GetSearchedUserEvent(query: val.trim()));
          }
        },
      ),
    );
  }
}
