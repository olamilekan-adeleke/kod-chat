import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  String email;
  String name;
  String uid;
  String imageUrl;
  Timestamp timestamp;
  Timestamp lastSeen;
  List searchKeys;

  UserModel({
    @required this.email,
    @required this.name,
    @required this.uid,
    @required this.imageUrl,
    @required this.timestamp,
    @required this.lastSeen,
    this.searchKeys,
  });

  Map<String, dynamic> toMap() {
    List<String> _searchKeys = [];

    /// this is for the whole full name. so the name ola lekan will be turn to an
    /// array of string "['o', 'ol', 'ola' 'ola ', 'ola l' 'ola le', 'ola lek', 'ola leka', 'ola lekan']"

    String currentIteration = '';

    name.split('').forEach((element) {
      currentIteration += element.toLowerCase();
      _searchKeys.add(currentIteration);
    });

    return {
      'email': this.email,
      'name': this.name,
      'uid': this.uid,
      'imageUrl': this.imageUrl,
      'timestamp': this.timestamp,
      'lastSeen': this.lastSeen,
      'searchKeys': _searchKeys,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return new UserModel(
      email: map['email'] as String,
      name: map['name'] as String,
      uid: map['uid'] as String,
      imageUrl: map['imageUrl'] as String,
      timestamp: map['timestamp'] as Timestamp,
      lastSeen: map['lastSeen'] as Timestamp,
      searchKeys: map['searchKeys'] as List,
    );
  }
}
