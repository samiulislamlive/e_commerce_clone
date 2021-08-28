import 'dart:io';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _cPasswordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imagefile;
  @override
  Widget build(BuildContext context) {
    double _screenwidth = MediaQuery.of(context).size.width, _screenheight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: ()=> print("Selected"),
              child: CircleAvatar(
                radius: _screenwidth*0.15,
                backgroundColor: Colors.white,
                backgroundImage: _imagefile==null ? null: FileImage(_imagefile),
                child: _imagefile == null
                    ? Icon(Icons.add_photo_alternate, size: _screenwidth*0.15, color: Colors.grey,)
                : null,
              ),
            ),
            SizedBox(
              height: 8.0,
            )
            Form(
              key: _formkey,
              child: Column(
                Custom
              ),
            )
          ],
        ),
      ),
    );
  }
}

