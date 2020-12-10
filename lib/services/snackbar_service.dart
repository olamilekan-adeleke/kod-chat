import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  BuildContext _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String message) {
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 4),
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    ));
  }

  void showSnackBarSucess(String message) {
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      backgroundColor: Colors.green,
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    ));
  }
}
