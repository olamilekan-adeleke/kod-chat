import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kodchat/services/navigation_service.dart';
import 'package:kodchat/services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  User user;
  AuthStatus status;

  FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  Future<void> _autoLogin() async {
    if (user != null) {
      await Future.delayed(Duration(milliseconds: 500));
      NavigationService.instance.navigateToReplacement('home');
    }
  }

  Future<void> _checkCurrentUserIsAuthenticated() {
    user = _auth.currentUser;

    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void loginUserWithEmailAndPassword({String email, String password}) async {
    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = result.user;
      status = AuthStatus.Authenticated;

      /// update last seen time
      SnackBarService.instance.showSnackBarSucess('Welcome, ${user.email}');
      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError('Error Authenticating...');
      print('error: $e');

      /// display error
    }

    notifyListeners();
  }

  void registerUserWithEmailAndPassword({
    String email,
    String password,
    Future<void> onSuccess(String uid),
  }) async {
    status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = _result.user;
      status = AuthStatus.Authenticated;

      await onSuccess(user.uid);
      SnackBarService.instance.showSnackBarSucess('Welcome, ${user.email}');

      /// update last seen time
      NavigationService.instance.navigateBack();
      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError('Error: ${e.message}');
    }
    notifyListeners();
  }

  void logOutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement('login');
      SnackBarService.instance.showSnackBarSucess('Logged Out Sucessfully');
    } catch (e) {
      print(e);
      SnackBarService.instance.showSnackBarError('Error Logging Out');
    }
  }
}
