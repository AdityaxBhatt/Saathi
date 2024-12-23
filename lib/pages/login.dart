import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saathi/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saathi/pages/userprofile.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    hostedDomain: "",
    clientId: "",
  );

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Access the user information
      final User? user = authResult.user;

      // Check if the user is new
      if (authResult.additionalUserInfo!.isNewUser) {
        // The user is new, navigate to the user profile screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserProfilePage()),
        );
      } else {
        // The user is not new, navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDE0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset('assets/images/logo1.png'),
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: EdgeInsets.only(left: 50, right: 50, top: 0),
                child: Divider(),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: () => _handleSignIn(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 8),
                          child: Image(
                            image: AssetImage(
                                "assets/images/free-google-1772223-1507807.webp"),
                            width: 50,
                            height: 50,
                          ),
                        ),
                        Text(
                          "Contiue with google",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Make your trip easy",
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
