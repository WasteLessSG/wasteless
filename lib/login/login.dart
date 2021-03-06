import 'package:WasteLess/login/forgot-password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:WasteLess/home.dart';

/**
 * Initialises login screen
 */
class Login extends StatefulWidget {

  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<Login> {
  String email, password;
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  void initState() {
    _obscureText = true;
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  /**
   * scaffold for login page
   */
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    print(size.height);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 81, 40, 1),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Color.fromRGBO(0, 81, 40, 1),
        body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(

                  children: <Widget>[
                    SizedBox(
                      height: size.height *0.05 ,
                    ),

                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: size.height *0.040 ,
                          ),
                          RichText(text: TextSpan(
                              text: "WasteLess ",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Beta 0.5",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )

                              ]),
                          ),
                          SizedBox(
                            height: size.height *0.03 ,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[200],
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => email = value.trim(),
                              cursorColor: Color.fromRGBO(32, 95, 38, 1) ,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.email,
                                  color: Color.fromRGBO(32, 95, 38, 1) ,
                                ),
                                hintText: 'Enter your email',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[200],
                              borderRadius: BorderRadius.circular(29),
                            ),
                            child: TextField(
                              controller: passwordController,
                              autocorrect: false,
                              obscureText: _obscureText,
                              // onChanged: (value) => password = value,
                              cursorColor: Color.fromRGBO(32, 95, 38, 1) ,
                              decoration: InputDecoration(
                                icon: Icon(Icons.lock, color: Color.fromRGBO(32, 95, 38, 1),),
                                hintText: "Enter your password",
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Color.fromRGBO(32, 95, 38, 1) ,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          LoginButton(
                            title: "LOGIN",
                            callback: signIn,
                          ),
                          SizedBox(height: size.height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Forgot your password? ",
                                style: TextStyle(color: Color.fromRGBO(32, 95, 38, 1) ),),
                              GestureDetector(
                                onTap: _forgetPassword,
                                child: Text(
                                  "Get help signing in.",
                                  style: TextStyle(
                                    color: Color.fromRGBO(32, 95, 38, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.height *0.05 ,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height *0.065 ,
                    ),

                    Image.asset('assets/nusLogo.png'),
                  ], ),
              ),
            ),
          ),
        ),
    );
  }

  Future<void> signIn() async{
    password = passwordController.text;
    print(password);
    try {
      FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)).user;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> new HomePage(user)));
    } catch (e) {
      _showAlertDialog("ERROR",e.message );
      passwordController.clear();
    }

  }

  /**
   * helper function to direct user to forget-password page
   */
  void _forgetPassword(){
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => new ForgotPasswordPage(),
        transitionDuration: Duration(seconds: 0),
      ),
    );


  }

  /**
   * helper function for alert
   */
  void _showAlertDialog( String title, String message ) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

}


/**
 * login button to go to dashboard page
 */
class LoginButton extends StatelessWidget {
  final String title;
  final VoidCallback callback;

  const LoginButton({Key key, this.title, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Container(
      // margin: EdgeInsets.symmetric(vertical: 10),
    width: size.width * 0.8,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(29),
    child: FlatButton(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
    color: Color.fromRGBO(32, 95, 38, 1) ,
    onPressed: callback,
    child: Text(
    title,
    style: TextStyle(color: Colors.lightGreen),
    ),
    ),
    ),
    ));
  }
}
