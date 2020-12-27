import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier {
  String _tokenId;
  DateTime _tokenExpiresTime;
  String _userId;
  Timer _authTimer;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD72-SsZirPEuGB6WXTJrUvcAnBOaK732E";
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      var responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _tokenId = responseData["idToken"];
      _tokenExpiresTime = DateTime.now().add(Duration(
        seconds: int.parse(responseData["expiresIn"]),
      ));
      _userId = responseData["localId"];
      autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "tokenId": _tokenId,
        "tokenExpiresDate": _tokenExpiresTime.toIso8601String(),
        "userId": _userId,
      });
      prefs.setString("userData", userData);
    } catch (error) {
      throw error;
    }
  }

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_tokenId != null &&
        _tokenExpiresTime != null &&
        _tokenExpiresTime.isAfter(DateTime.now())) {
      return _tokenId;
    }
    return null;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> logOut() async {
    _tokenExpiresTime = null;
    _tokenId = null;
    _userId = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove("userData");
    prefs.clear();
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userData")) {
      return false;
    }

    final userData =
        json.decode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(userData["tokenExpiresDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _tokenId = userData["tokenId"];
    _tokenExpiresTime = expiryDate;
    _userId = userData["userId"];

    notifyListeners();
    autoLogOut();
    return true;
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _tokenExpiresTime.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
