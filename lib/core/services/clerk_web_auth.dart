import 'clerk_web_auth_stub.dart'
    if (dart.library.html) 'clerk_web_auth_web.dart'
    as platform;

class ClerkWebUser {
  const ClerkWebUser({required this.id, this.email});

  final String id;
  final String? email;
}

class ClerkWebAuth {
  ClerkWebAuth._();

  static Future<void> initialize() => platform.initialize();

  static Future<ClerkWebUser?> currentUser() async {
    final user = await platform.currentUser();
    if (user == null) return null;
    final id = user['id'];
    if (id == null || id.isEmpty) return null;
    return ClerkWebUser(id: id, email: user['email']);
  }

  static Stream<ClerkWebUser?> get authChanges =>
      platform.authChanges.map((user) {
        final id = user?['id'];
        if (id == null || id.isEmpty) return null;
        return ClerkWebUser(id: id, email: user?['email']);
      });

  static Future<String?> sessionToken() => platform.sessionToken();

  static Future<void> openSignIn() => platform.openSignIn();

  static Future<void> openSignUp() => platform.openSignUp();

  static Future<void> signOut() => platform.signOut();
}
