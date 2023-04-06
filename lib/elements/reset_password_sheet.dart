import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/helpers/shared_pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:mdi/mdi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app/repository/user_repository.dart';
import '../appColors.dart';

SharedPreferences prefs;

class ResetPasswordSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String email;
  ResetPasswordSheet(this.scaffoldKey, this.email);

  @override
  _ResetPasswordSheetState createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  var width, height;
  bool showtextInput = false;
  UserController userController;

  void showToast(text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

//key for validation of input fields
  GlobalKey<FormState> key = GlobalKey<FormState>();
  var email, password;
  String _id;
  String _otp;
  @override
  void initState() {
    userController = UserController();
    getValuesofShared();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          _buildTextFields(),
          SizedBox(
            height: 20.0,
          ),
          _buildSignInButton(context),
          SizedBox(
            height: 0.05 * height,
          ),
        ],
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController.resetFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.length <= 0 && v.length > 5) {
                    return allMessages.value.enterAValidOtp;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.otp = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.numeric),
                    hintText: allMessages.value.otp,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v.length <= 0) {
                    return allMessages.value.enterAValidPassword;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.password = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.key),
                    hintText: allMessages.value.password,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (v) {
                  if (v.length <= 0) {
                    return "allMessages.value.enterAValidPassword";
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.cpassword = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.lockQuestion),
                    hintText:
                        allMessages.value.reEnterPassword, //allMessages.value.
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
        ],
      ),
    );
  }

  _buildSignInButton(BuildContext context) {
    return Center(
      child: ButtonTheme(
        minWidth: 0.85 * width,
        height: 0.075 * height,
        child: RaisedButton(
          color: appMainColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Text(
            allMessages.value.resetPassword,
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            setState(() {
              userController.resetPassword(widget.scaffoldKey, widget.email);
            });
          },
        ),
      ),
    );
  }

  void getValuesofShared() async {
    prefs = GetIt.instance<SharedPreferencesUtils>().prefs;
    _otp = prefs.getString('otp');
  }
}
