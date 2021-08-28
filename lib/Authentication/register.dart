import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              onTap: _selectAndPickImage,
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
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameTextEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordTextEditingController,
                    data: Icons.person,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: (){
                  uploadAndSaveImage();
                },
                child: Text(
                  "Sign Up", style: TextStyle(
                  color: Colors.white,
                ),
                )),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenwidth*0.8,
              color: Colors.blue,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );

  }
  Future<void> _selectAndPickImage() async
  {
    _imagefile =await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadAndSaveImage() async
  {
    if(_imagefile == null)
      {
        showDialog(
          context: context,
          builder: (c)
            {
              return ErrorAlertDialog(message: "Please Select an Image",);
            }
        );
      }
    else
      {
        _passwordTextEditingController.text == _cPasswordTextEditingController.text
            ? _emailTextEditingController.text.isNotEmpty &&
            _passwordTextEditingController.text.isNotEmpty &&
            _cPasswordTextEditingController.text.isNotEmpty &&
            _nameTextEditingController.text.isNotEmpty

            ? uploadToStorage()
            : displayDialog("Please fill the form")
            : displayDialog("Password is incorrect");
      }
  }

  displayDialog(String msg){
    showDialog(
      context: context,
      builder: (c){
        return ErrorAlertDialog(message: msg,);
      }
    );
  }
  uploadToStorage() async {
    showDialog(
      context: context,
      builder: (c){
        return LoadingAlertDialog(message: "Authentication is on process",);
      }
    );

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_imagefile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((urlImage){
      userImageUrl = urlImage;
      _registerUser();
    });
  }
  
  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async{
    FirebaseUser firebaseUser;
    await _auth.createUserWithEmailAndPassword(
        email: _emailTextEditingController.text.trim(),
        password: _passwordTextEditingController.text.trim()
    ).then((auth){
      firebaseUser = auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c)
          {
            return ErrorAlertDialog(message: error.message.toString(),);
          }
      );
    });

    if(firebaseUser!=null)
      {
        saveUserInfoToFireStore(firebaseUser).then((value){
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder:(c) => StoreHome());
          Navigator.pushReplacement(context, route);
        });
      }
  }
  Future saveUserInfoToFireStore(FirebaseUser fUser) async
  {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameTextEditingController.text.trim(),
      "url": userImageUrl,

    });

    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userUID, fUser.uid);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, fUser.email);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, _nameTextEditingController.text);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}

