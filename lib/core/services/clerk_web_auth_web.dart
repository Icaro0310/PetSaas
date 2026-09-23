import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

final StreamController<Map<String, String?>?> _authChanges =
    StreamController<Map<String, String?>?>.broadcast();

_ClerkWebApi? _clerk;
bool _initialized = false;

@JS()
extension type _ClerkWebApi._(JSObject _) implements JSObject {
  external JSString? getUser();
  external JSPromise<JSString?> getToken();
  external void signIn();
  external void signUp();
  external JSPromise<JSAny?> signOut();
  external void subscribe(JSFunction callback);
}

Stream<Map<String, String?>?> get authChanges => _authChanges.stream;

Future<void> initialize() async {
  if (_initialized) return;
  JSAny? ready;
  for (var attempt = 0; attempt < 100; attempt++) {
    ready = globalContext['PetCareClerkReady'];
    if (ready != null) break;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  if (ready == null) throw StateError('ClerkJS did not initialize');
  final api = await (ready as JSPromise<JSObject>).toDart;
  _clerk = _ClerkWebApi._(api);
  _initialized = true;
  _clerk!.subscribe(_onAuthChange.toJS);
  _authChanges.add(await currentUser());
}

Future<Map<String, String?>?> currentUser() async {
  await initialize();
  final value = _clerk!.getUser()?.toDart;
  if (value == null || value == 'null') return null;
  final decoded = jsonDecode(value) as Map<String, dynamic>;
  return {'id': decoded['id'] as String?, 'email': decoded['email'] as String?};
}

Future<String?> sessionToken() async {
  await initialize();
  return (await _clerk!.getToken().toDart)?.toDart;
}

Future<void> openSignIn() async {
  await initialize();
  _clerk!.signIn();
}

Future<void> openSignUp() async {
  await initialize();
  _clerk!.signUp();
}

Future<void> signOut() async {
  await initialize();
  await _clerk!.signOut().toDart;
}

void _onAuthChange(JSString? value) {
  final json = value?.toDart;
  if (json == null || json == 'null') {
    _authChanges.add(null);
    return;
  }
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  _authChanges.add({
    'id': decoded['id'] as String?,
    'email': decoded['email'] as String?,
  });
}
