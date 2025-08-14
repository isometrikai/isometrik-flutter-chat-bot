

class AuthRepository {

  //  Future<AuthResponse> signInWithGoogle() async {
  //   try {
  //     await GoogleSignIn.instance.initialize();
  //     // Start Google Sign-In process
  //     final googleUser = await GoogleSignIn.instance.authenticate(
  //       scopeHint: ['email'],
  //     );
  //     final idToken = googleUser.authentication.idToken;
  //     if (idToken == null) {
  //       throw Exception('Missing Google ID token');
  //     }
  //     // Sign in with Supabase
  //     final authResponse =
  //         await SupabaseService().client.auth.signInWithIdToken(
  //               provider: OAuthProvider.google,
  //               idToken: idToken,
  //             );
  //     final displayName = googleUser.displayName;
  //     final email = googleUser.email;
  //     // final photoUrl = googleUser.photoUrl;

  //     // Splitting full name into given name and family name
  //     final nameParts = displayName?.split(' ');
  //     final givenName = nameParts?.first;
  //     final familyName = (nameParts != null && nameParts.length > 1)
  //         ? nameParts.sublist(1).join(' ')
  //         : null;
  //     final metadata = authResponse.user?.userMetadata;
  //     await _updateMissingNameAttributes(
  //       metadata: metadata,
  //       email: email,
  //       firstName: givenName,
  //       lastName: familyName,
  //     );
  //     service.postUserSession();
  //     UserSessionManager.deletePendingUserData();
  //     return authResponse;
  //   } catch (e) {
  //     debugPrint('Google sign-in error: $e');
  //     rethrow;
  //   }
  // }
}