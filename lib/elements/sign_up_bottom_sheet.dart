import 'package:blog_app/controllers/user_controller.dart';
import 'package:blog_app/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:blog_app/elements/sign_in_bottom_sheet.dart';

import '../appColors.dart';

class SignUpBottomSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignUpBottomSheet(this.scaffoldKey);
  @override
  _SignUpBottomSheetState createState() => _SignUpBottomSheetState();
}

class _SignUpBottomSheetState extends State<SignUpBottomSheet> {
  UserController userController;
  var width, height;

  GlobalKey<FormState> key = GlobalKey<FormState>();
  var email, password;
  @override
  void initState() {
    userController = UserController();
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
            height: 20,
          ),
          _buildSignInButton(context),
          _buildOldUserRichText(),
        ],
      ),
    );
  }

  _buildTextFields() {
    return Form(
      key: userController.signupFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  bool emailValid =
                      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                          .hasMatch(v);
                  if (v.length <= 0) {
                    return allMessages.value.enterAValidEmail;
                  } else if (!emailValid) {
                    return allMessages.value.enterAValidEmail;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.email = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.email),
                    hintText: allMessages.value.email,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.length <= 0) {
                    return allMessages.value.enterAValidPhoneNumber;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.phone = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.phone),
                    hintText: allMessages.value.phoneNumber,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                validator: (v) {
                  if (v.length <= 0) {
                    return allMessages.value.enterAValidUserName;
                  }
                  return null;
                },
                onSaved: (v) {
                  setState(() {
                    userController.user.name = v;
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.faceProfile),
                    hintText: allMessages.value.userName,
                    hintStyle: Theme.of(context).textTheme.headline6),
                style: Theme.of(context).textTheme.headline6),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
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
                obscureText: userController.hidePassword,
                decoration: InputDecoration(
                    prefixIcon: Icon(Mdi.key),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          userController.hidePassword =
                              !userController.hidePassword;
                        });
                      },
                      color: Theme.of(context).focusColor,
                      icon: Icon(userController.hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: allMessages.value.password,
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
            allMessages.value.signUp,
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            userController.register(widget.scaffoldKey);
          },
        ),
      ),
    );
  }

  _buildOldUserRichText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return SignInBottomSheet(widget.scaffoldKey);
                });
          },
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: allMessages.value.alreadyHaveAnAccount,
                  style: Theme.of(context).textTheme.headline6),
              TextSpan(
                  text: ' ${allMessages.value.signIn}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: appMainColor))
            ]),
          ),
        ),
      ),
    );
  }
}
