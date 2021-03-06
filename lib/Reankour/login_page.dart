import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class LoginPage extends StatefulWidget{
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

enum FormType{
  login,
  register
}
class _LoginPageState extends State<LoginPage>{

  FirebaseUser myUser;
  bool _isLoading;
  bool _isIos;
  String _errorMessage;
  String _email;
  String _password;

  FormType _formType = FormType.login;
  final formKey = new GlobalKey<FormState>();
  bool isLogged = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
     _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    TextStyle textstyle = Theme.of(context).textTheme.title;
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        title: Text("ReanKour"),
      ),
      body: new Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress(),
        ],
      ),
    );
  }

//Function show body 
Widget _showBody(){
  return new Container(
    padding: EdgeInsets.all(1),
    child: new Form(
      key: formKey,
      child: ListView(
        children: <Widget>[
          _getImageAsset(),
          _showInputEmail(),
          _showInputPassword(),
          _showPrimaryButton(),
          _showFacebookLogin(),
          _showSecondaryButton(),
          _showErrorMessage(),
        ],
      ),
    ),
  );
}


//Function show progress bar
Widget _showCircularProgress(){
  if (_isLoading)  {
    return Center(child: CircularProgressIndicator());
  } return Container(height: 0.0, width: 0.0,);
}

//Function Add logo
  Widget _getImageAsset(){
    AssetImage assetImage = AssetImage('images/logo.ico');
    Image image = Image(image: assetImage,width: 200.0,height: 200.0,);
    return Container(child: image,margin: EdgeInsets.all(5.0),);
  }

//Function input email 
Widget _showInputEmail(){
  TextStyle textstyle = Theme.of(context).textTheme.title;
    return Padding(
      padding: EdgeInsets.all(1.0),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: TextFormField(
            style: textstyle,
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: (String value){
              if (value.isEmpty){
                return "Email cannot blank";
              }
            },
            onSaved: (value) => _email = value,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: textstyle,
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 10.0,
              ),
              hintText: "Please enter email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ), 
      );
}
//Function input password
Widget _showInputPassword(){
  TextStyle textstyle = Theme.of(context).textTheme.title;
  return Padding(
    padding: EdgeInsets.all(1.0),
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: TextFormField(
        style: textstyle,
        // keyboardType: TextInputType.number,
        obscureText:true,
        controller: passwordController,
        validator: (String value){
          if (value.isEmpty){
            return "Password cannot blank";
          }
        },
        onSaved: (value) => _password = value,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: textstyle,
          errorStyle: TextStyle(
            color: Colors.red,
            fontSize: 10.0,
          ),
          hintText: "Plese enter Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    ),
  );
}

// Function check button login or sign up
Widget _showPrimaryButton(){
  return Padding(
    padding: EdgeInsets.all(10.0),
    child: RaisedButton(
      color: Colors.blueAccent,
      textColor: Colors.white,
      child: _formType == FormType.login? 
        new Text("Login",style: new TextStyle(fontSize: 20)) :
        new Text("Register",style: new TextStyle(fontSize: 20)),
        onPressed: _validateAndSubmit,
    ),
  );
}

//Function check whether user have account or not
Widget _showSecondaryButton(){
  return Padding(
    padding: EdgeInsets.all(10.0),
    child: new FlatButton(
      child: _formType == FormType.login? 
            new Text("Create a new account?",textAlign: TextAlign.center,style: new TextStyle(color: Colors.blue,fontSize: 20.0,), ) 
          : new Text("Have account yet?",textAlign: TextAlign.center,style: new TextStyle(color: Colors.blue,fontSize: 20.0,), ) ,
      onPressed: _formType == FormType.login? moveToRegister : moveToLogin,
    ),
  );
}

  // Function show facebook login

  Widget _showFacebookLogin(){
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: isLogged? new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "Name" + myUser.displayName,
          )
        ],
      ) : FacebookSignInButton(onPressed: _login,),
    );
  }

  //Check condition when login with facebook
  Future <FirebaseUser> _loginWithFacebook() async{
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn){
      FirebaseUser user = 
        await _auth.signInWithFacebook(accessToken: result.accessToken.token)
              .then((onValue){
                isLogged == true;
              });
      return user;
    }
    return null;
  }

  //Function login with facebook
  void _login(){
    _loginWithFacebook().then((response){
      if (response != null){
        myUser = response;
        isLogged == true;
        setState(() {
          
        });
      }
    });
  }

  //Function logout in facebook
  void _logout() async{
    await _auth.signOut().then((response){
      isLogged == false;
      setState(() {
      });
    });
  }

  //Function check validation when submit 
  bool validateAndSave(){
    final form = formKey.currentState;
    if (form.validate()){
      form.save();
      return true;
    } 
    return false;
  }
  _validateAndSubmit() async{
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()){
      String userId = "";
      try{
        if (_formType == FormType.login){
           userId =  await widget.auth.signIn(_email, _password);
          print ("SignUp: ${userId}");
        }else{
           userId = await widget.auth.signUp(_email,_password);
          print ("Registerd user:${userId}");
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null) {
          widget.onSignedIn();
          debugPrint("$userId");
        }
      }
      catch(e){
        _isLoading = false;
        print("Error $e");
        if(_isIos){
          _errorMessage = e.details;
        } else {
          _errorMessage = e.message;
        }
      }
    }
  }

  //Validation the form
  void _validationForm(){
    if (formKey.currentState.validate()){
       FormType.login;
    } else{
      FormType.register;
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void moveToRegister(){
    formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin(){
    formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formType = FormType.login;
    });
  }

  //Show error message
  Widget _showErrorMessage() {
    debugPrint("Error message");
    if (_errorMessage.length > 0 && _errorMessage != null) {
      debugPrint("Here is $_errorMessage");
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}