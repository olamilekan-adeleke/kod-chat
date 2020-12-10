import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MessageType {
  Text,
  Image,
}

class MessageModel {
  String body;
  MessageType type;
  String senderId;
  Timestamp timestamp;
  bool isSent;

  MessageModel({
    @required this.body,
    @required this.type,
    @required this.senderId,
    @required this.timestamp,
    this.isSent,
  });

  Map<String, dynamic> toMap() {
    String _type;

    if (this.type == MessageType.Text) {
      _type = 'text';
    } else if (this.type == MessageType.Image) {
      _type = 'image';
    }

    return {
      'body': this.body,
      'type': _type,
      'senderId': this.senderId,
      'timestamp': this.timestamp,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, bool sent) {
    MessageType _type;

    if (map['type'] == 'text') {
      _type = MessageType.Text;
    } else if (map['type'] == 'image') {
      _type = MessageType.Image;
    }

    return new MessageModel(
      body: map['body'] as String,
      type: _type,
      senderId: map['senderId'] as String,
      timestamp: map['timestamp'] as Timestamp,
      isSent: sent,
    );
  }
}
