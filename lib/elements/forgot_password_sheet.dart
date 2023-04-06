import 'package:blog_app/controllers/user_controller.dart';
import 'package:flutter/material.dart';

import 'package:mdi/mdi.dart';

import '../appColors.dart';
import 'package:blog_app/repository/user_repository.dart';

class ForgotPasswordSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  ForgotPasswordSheet(this.scaffoldKey);

  @override
  _ForgotPasswordSheetState createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  var width, height;
  UserController userController;

//key for validation of input fields
  GlobalKey<FormState> key = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: userController.forgetFormKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v.length <= 0) {
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
                    prefixIcon: Icon(Mdi.account),
                    hintText: allMessages.value.email,
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
            allMessages.value.submit,
            style: Theme.of(context).textTheme.headline3,
          ),
          onPressed: () {
            userController.forgetPassword(widget.scaffoldKey, context);
          },
        ),
      ),
    );
  }
}
