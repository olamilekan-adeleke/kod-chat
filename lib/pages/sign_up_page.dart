import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kodchat/provider/auth_provider.dart';
import 'package:kodchat/services/cloud_storage.dart';
import 'package:kodchat/services/database_service.dart';
import 'package:kodchat/services/media_servivce.dart';
import 'package:kodchat/services/navigation_service.dart';
import 'package:kodchat/services/snackbar_service.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  AuthProvider _auth;
  File _image;
  Size _size;
  String _email;
  String _name;
  String _password;

  void registerUser() {
    if (_formKey.currentState.validate() && _image != null) {
      _auth.registerUserWithEmailAndPassword(
        email: _email,
        password: _password,
        onSuccess: (uid) async {
          var imageUrl = await CloudStorageService.instance.uploadProfileImage(
            uid: uid,
            image: _image,
          );

          await DatabaseService.instance.createUserInDb(
            email: _email,
            name: _name,
            imageUrl: imageUrl,
            uid: uid,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _signUpPageUi(),
        ),
      ),
    );
  }

  Widget _signUpPageUi() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _size.height * 0.75,
          padding: EdgeInsets.symmetric(horizontal: _size.width * 0.10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _headingWidget(),
                SizedBox(height: 20),
                _inputForm(),
                SizedBox(height: 20),
                _signUpButton(),
                SizedBox(height: 20),
                _loginButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _size.height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get going',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            'Please eneter your details.',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _size.height * 0.40,
      child: Form(
        onChanged: () {
          _formKey.currentState.save();
        },
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () async {
          _image = await MediaService.instance.getImageFromGallery();
          setState(() {});
        },
        child: Container(
          height: _size.height * 0.10,
          width: _size.height * 0.10,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(500),
          ),
          child: _image == null
              ? Icon(Icons.person, color: Colors.grey)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: Image.file(
                    _image,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 ? null : 'Please Enter A Vaild Username';
      },
      onChanged: (input) => setState(() {
        _name = input;
      }),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Username',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: true,
      style: TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 && input.contains('@')
            ? null
            : 'Please Enter A Vaild Email';
      },
      onChanged: (input) {
        setState(() {
          _email = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Email Address',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (input) {
        return input.length != 0 ? null : 'Please Enter A Vaild Password';
      },
      onChanged: (input) => setState(() {
        _password = input;
      }),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Password',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: _size.height * 0.06,
            width: _size.width,
            child: MaterialButton(
              color: Colors.blue,
              onPressed: () {
                registerUser();
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
  }

  Widget _loginButton() {
    return InkWell(
      onTap: () {
        NavigationService.instance.navigateBack();
      },
      child: Container(
        alignment: Alignment.center,
        height: _size.height * 0.06,
        width: _size.width,
        child: Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }
}
