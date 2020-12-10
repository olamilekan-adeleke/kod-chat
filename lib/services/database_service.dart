import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kodchat/model/user_model.dart';
import 'package:kodchat/provider/auth_provider.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();
  FirebaseFirestore _db;
  String userCollectionRef = 'users';

  DatabaseService() {
    _db = FirebaseFirestore.instance;
  }

  Future<void> createUserInDb({
    String uid,
    String name,
    String email,
    String imageUrl,
  }) async {
    UserModel user = UserModel(
      email: email,
      name: name,
      uid: uid,
      imageUrl: imageUrl,
      timestamp: Timestamp.now(),
      lastSeen: Timestamp.now(),
    );
    try {
      return await _db.collection(userCollectionRef).doc(uid).set(user.toMap());
    } catch (e) {
      print(e);
    }
  }

  Future<UserModel> getUserDetails() async {
    UserModel userModel;
    String userUid = AuthProvider.instance.user.uid;
    try {
      DocumentSnapshot documentSnapshot =
          await _db.collection(userCollectionRef).doc(userUid).get();
      userModel = UserModel.fromMap(documentSnapshot.data());
    } catch (e) {
      throw Exception(e.message.toString());
    }

    return userModel;
  }

  Future<List<UserModel>> searchUserByKeyWord(String keyWord) async {
    List<UserModel> users = [];

    try {
      QuerySnapshot querySnapshot = await _db
          .collection(userCollectionRef)
          .where('searchKeys', arrayContains: keyWord)
          .get();

      querySnapshot.docs.forEach((element) {
        UserModel _user = UserModel.fromMap(element.data());
        users.add(_user);
      });
    } catch (e) {
      print(e);
      throw Exception('$e');
    }

    //TODO: add pagination later on

    return users;
  }


}
