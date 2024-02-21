import 'package:google_sign_in/google_sign_in.dart';


class TeacherAuthenticationServices{
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Get the GoogleSignInAccount object and send the token to the backend
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final String googleToken = googleAuth.accessToken!;
      print(googleToken);
      // Send the Google access token to your backend 
      // await sendTokenToBackend(googleToken);
      
      // Perform additional tasks in your app, e.g., navigate to the home screen
    } catch (error) {
      print('Google Sign-In failed: $error');
      // Handle sign-in failure
    }
  }
}