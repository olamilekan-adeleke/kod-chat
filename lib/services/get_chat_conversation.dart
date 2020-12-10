import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kodchat/model/message_model.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/provider/auth_provider.dart';
import 'package:path/path.dart';

class GetChatConversation {
  final String id;

  GetChatConversation({this.id}) {
    getConversations();
  }

  StreamController<List<MessageModel>> conversationStream =
      StreamController<List<MessageModel>>.broadcast();

  void getConversations() {
    Query query = FirebaseFirestore.instance
        .collection('Conversations')
        .doc(id)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    query.snapshots(includeMetadataChanges: true).listen((eventSnapshot) {
      List<MessageModel> messageList = eventSnapshot.docs.map((e) {
        bool x = e.metadata.hasPendingWrites;
        return MessageModel.fromMap(e.data(), x);
      }).toList();

      conversationStream.add(messageList);
    });
  }
}

class SendMessageMethod extends ChangeNotifier {
  static SendMessageMethod instance = SendMessageMethod();

  ValueNotifier<Map<String, Map>> sendingValue =
      ValueNotifier<Map<String, Map>>({});

  Future<String> getConversationId(String receiverId) async {
    try {
      String userId = AuthProvider.instance.user.uid;

      print("[${userId.toString()}, ${receiverId.toString()}]");
      print("[${receiverId.toString()}, ${userId.toString()}]");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Conversations')
          .where('membersForSearch', whereIn: [
        "[${userId.toString()}, ${receiverId.toString()}]",
        "[${receiverId.toString()}, ${userId.toString()}]"
      ]).get();

      if (snapshot.docs.isEmpty) {
        String id = await initChat(receiverId);
        return id;
      }

      String docId = snapshot.docs[0].id;
      return docId;
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<void> sendMessage({MessageModel message, String docID}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.set(
        FirebaseFirestore.instance
            .collection('Conversations')
            .doc(docID)
            .collection('messages')
            .doc(),
        message.toMap(),
      );

      batch.set(
          FirebaseFirestore.instance.collection('Conversations').doc(docID),
          {
            'lastMessage': message.toMap(),
            'timestamp': message.timestamp,
          },
          SetOptions(merge: true));

      await batch.commit();
      print('send');
    } catch (e) {
      print(e);
    }
  }

  Future<String> initChat(String receiverId) async {
    String senderId = AuthProvider.instance.user.uid;

    DocumentSnapshot receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();

    DocumentSnapshot senderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();

    UserModel senderData = UserModel.fromMap(senderDoc.data());
    UserModel receiverData = UserModel.fromMap(receiverDoc.data());

    DocumentReference ref =
        FirebaseFirestore.instance.collection('Conversations').doc();

    await ref.set(
      {
        'members': [senderId, receiverId],
        'membersForSearch': [senderId, receiverId].toString(),
        'owner': senderId,
        '$senderId': {
          'name': senderData.name,
          'imageUrl': senderData.imageUrl,
        },
        '${receiverData.uid}': {
          'name': receiverData.name,
          'imageUrl': receiverData.imageUrl,
        }
      },
      SetOptions(merge: true),
    );

    return ref.id;
  }

  Future<void> sendMessageToFirstTime(
      {MessageModel message, String docID, String receiverId}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentSnapshot receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      DocumentSnapshot senderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(message.senderId)
          .get();

      UserModel senderData = UserModel.fromMap(senderDoc.data());
      UserModel receiverData = UserModel.fromMap(receiverDoc.data());

      batch.set(
        FirebaseFirestore.instance
            .collection('Conversations')
            .doc(docID)
            .collection('messages')
            .doc(),
        message.toMap(),
      );

      batch.set(
          FirebaseFirestore.instance.collection('Conversations').doc(docID),
          {
            'members': [message.senderId, receiverId],
            'membersForSearch': [message.senderId, receiverId].toString(),
            'owner': message.senderId,
            'lastMessage': message.toMap(),
            'timestamp': message.timestamp,
            '${message.senderId}': {
              'name': senderData.name,
              'imageUrl': senderData.imageUrl,
            },
            '${receiverData.uid}': {
              'name': receiverData.name,
              'imageUrl': receiverData.imageUrl,
            }
          },
          SetOptions(merge: true));

      await batch.commit();
      print('send');
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadImage({File image, String docId}) async {
    String userUid = AuthProvider.instance.user.uid;

    String imageUrl;
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref('chats')
        .child(userUid)
        .child(basename(image.path) + DateTime.now().toString());

    UploadTask uploadTask = ref.putFile(image);

    uploadTask.snapshotEvents.listen((event) {
      if (event.state == TaskState.running) {
        Map sendingMap = {
          'id': docId,
          'number': 1,
          'value': 0,
          'total': event.totalBytes,
        };

        sendingValue.value.putIfAbsent(docId, () => sendingMap);
        sendingValue.notifyListeners();

        sendingMap.update('value', (value) => event.bytesTransferred);
        sendingValue.value.update(docId, (value) => sendingMap);
        sendingValue.notifyListeners();
      }
    });
    try {
      await uploadTask;

      imageUrl = await ref.getDownloadURL();
      print(imageUrl);

      MessageModel message = MessageModel(
        body: imageUrl,
        type: MessageType.Image,
        senderId: userUid,
        timestamp: Timestamp.now(),
      );

      await sendMessage(
        message: message,
        docID: docId,
      );

      Map sendingMap = {
        'id': docId,
        'number': 1,
        'value': null,
        'total': null,
      };
      sendingValue.value.update(docId, (value) => sendingMap);
      sendingValue.notifyListeners();

      print('Upload complete.');
    } on FirebaseException catch (e) {
      Map sendingMap = {
        'id': docId,
        'number': 1,
        'value': null,
        'total': null,
      };
      sendingValue.value.update(docId, (value) => sendingMap);
      sendingValue.notifyListeners();

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }
  }

//  Future<void> sendingImage(String docId) async {
//    Map sendingMap = {
//      'id': docId,
//      'number': 1,
//      'value': 0,
//    };
//
//    sendingValue.value.putIfAbsent(docId, () => sendingMap);
//
//    sendingValue.notifyListeners();
//
//    Timer timer = Timer.periodic(Duration(seconds: 1), (timer) {
//      sendingMap.update('value', (value) => timer.tick);
//      sendingValue.value.update(docId, (value) => sendingMap);
//      sendingValue.notifyListeners();
//    });
//
//    await Future.delayed(Duration(seconds: 60), () {
//      timer.cancel();
//      sendingMap.update('value', (value) => null);
//      sendingValue.value.update(docId, (value) => sendingMap);
//      sendingValue.notifyListeners();
//    });
//  }
}
