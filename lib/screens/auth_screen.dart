import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode {
  Login,
  SignUp,
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Auth"),
      // ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        "MyShop",
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: "Anton",
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    )),
                    AuthCard(),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("An error has ocurred!"),
              content: Text(message),
              actions: [
                FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Okay"),
                )
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .logIn(_authData["email"], _authData["password"]);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData["email"], _authData["password"]);
      }
    } on HttpException catch (error) {
      var errorMessage = "We couldn authenticate you.";
      if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "This email is not registered";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "The password is invalid.";
      } else if (error.toString().contains("USER_DISABLED")) {
        errorMessage = "The user is disabled";
      } else if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This email has already been signup.";
      } else if (error.toString().contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
        errorMessage = "The user is temporaly locked, please try again later.";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = "Could not authenticate. Please try again later";
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // TODO: implement build
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.SignUp ? 360 : 300,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.SignUp ? 360 : 300,
        ),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: "E-Mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains("@")) {
                      return "Invalid email";
                    }
                  },
                  onSaved: (value) {
                    _authData["email"] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return "Password is too short!";
                    }
                  },
                  onSaved: (value) {
                    _authData["password"] = value;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.SignUp,
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    textInputAction: _authMode == AuthMode.SignUp
                        ? TextInputAction.done
                        : null,
                    obscureText: true,
                    onFieldSubmitted:
                        _authMode == AuthMode.SignUp ? (_) => _submit() : null,
                    validator: _authMode == AuthMode.SignUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return "Passwords do not match!";
                            }
                          }
                        : null,
                    onSaved: (value) {
                      _authData["password"] = value;
                    },
                  ),
                SizedBox(
                  height: 20.0,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.Login ? "LOGIN" : "SIGN UP"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 8.0,
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      "${_authMode == AuthMode.Login ? "SIGN UP" : "LOGIN"} INSTEAD"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          key: _formKey,
        ),
      ),
    );
  }
}
