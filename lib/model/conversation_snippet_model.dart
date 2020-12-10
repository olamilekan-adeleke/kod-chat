import 'package:flutter/material.dart';
import 'package:kodchat/model/message_model.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/provider/auth_provider.dart';

class ConversationSnippetModel {
  MessageModel lastMessage;
  UserModel otherUser;
  String docId;

  ConversationSnippetModel({
    @required this.lastMessage,
    @required this.otherUser,
    this.docId,
  });

  factory ConversationSnippetModel.fromMap(
      Map<String, dynamic> map, String id, bool sent) {
    String otherUserUid;
    String userUid = AuthProvider.instance.user.uid;

    map.forEach((key, value) {
      if (key.length > 20 && key != userUid) {
        otherUserUid = key;
      }
    });

    return new ConversationSnippetModel(
      lastMessage: MessageModel.fromMap(map['lastMessage'], sent),
      otherUser: UserModel.fromMap(map[otherUserUid]),
      docId: id,
    );
  }
}
