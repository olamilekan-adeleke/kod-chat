import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kodchat/model/conversation_snippet_model.dart';
import 'package:kodchat/provider/auth_provider.dart';

class GetChatList {
  static GetChatList instance = GetChatList();

  GetChatList() {
    _requestData();
  }

  final CollectionReference _conversationRef =
      FirebaseFirestore.instance.collection('Conversations');

  StreamController<List<ConversationSnippetModel>> conversationStream =
      StreamController<List<ConversationSnippetModel>>.broadcast();

  int _perPage = 10;
  DocumentSnapshot _lastDoc;
  bool isFetching = false;

  void _requestData() {
    String userUid = AuthProvider.instance.user.uid;
    Query query = _conversationRef
        .where('members', arrayContains: userUid)
        .orderBy('timestamp', descending: true)
        .limit(_perPage);

    isFetching = true;

    query.snapshots(includeMetadataChanges: true).listen((queryDataSnapshot) {
      List<ConversationSnippetModel> currentPageList =
          queryDataSnapshot.docs.map((e) {
        bool pendingWrite = e.metadata.hasPendingWrites;
        return ConversationSnippetModel.fromMap(e.data(), e.id, pendingWrite);
      }).toList();

      conversationStream.add(currentPageList);
    });
  }
}
