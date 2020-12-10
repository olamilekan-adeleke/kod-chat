import 'package:flutter/material.dart';
import 'package:kodchat/provider/auth_provider.dart';
import 'package:kodchat/services/navigation_service.dart';
import 'package:kodchat/services/snackbar_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  AuthProvider _auth;
  Size _size;
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUi(),
        ),
      ),
    );
  }

  Widget _loginPageUi() {
    _size = MediaQuery.of(context).size;
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _size.height * 0.60,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: _size.width * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingWidget(),
              _inputForm(),
              _loginButton(),
              _registerButton(),
            ],
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
            'Welcome Back',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            'Please login to your account.',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _size.height * 0.16,
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
            _emailTextField(),
            _passwordTextField(),
          ],
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
        if (!mounted) return;
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
      onChanged: (input) {
        if (!mounted) return;
        setState(() {
          _password = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Password',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: _size.height * 0.06,
            width: _size.width,
            child: MaterialButton(
              color: Colors.blue,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _auth.loginUserWithEmailAndPassword(
                    email: _email,
                    password: _password,
                  );
                }
              },
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return InkWell(
      onTap: () {
        NavigationService.instance.navigateTo('signup');
      },
      child: Container(
        alignment: Alignment.center,
        height: _size.height * 0.06,
        width: _size.width,
        child: Text(
          'Register',
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
