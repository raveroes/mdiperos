import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static final _scopes = [calendar.CalendarApi.calendarEventsScope];
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: _scopes);
  GoogleSignInAccount? _currentUser;
  http.Client? _authClient;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) return false;
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleAuthClient(authHeaders);
      _authClient = client;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _authClient = null;
    _currentUser = null;
  }

  Future<bool> addEventToCalendar({
    required String title,
    String? description,
    DateTime? start,
    DateTime? end,
  }) async {
    if (_authClient == null) {
      final success = await signIn();
      if (!success) return false;
    }
    final calendarApi = calendar.CalendarApi(_authClient!);
    final event = calendar.Event();
    event.summary = title;
    event.description = description;
    if (start != null) {
      event.start = calendar.EventDateTime(dateTime: start, timeZone: 'Asia/Jakarta');
    }
    if (end != null) {
      event.end = calendar.EventDateTime(dateTime: end, timeZone: 'Asia/Jakarta');
    } else if (start != null) {
      event.end = calendar.EventDateTime(dateTime: start.add(const Duration(hours: 1)), timeZone: 'Asia/Jakarta');
    }
    try {
      await calendarApi.events.insert(event, 'primary');
      return true;
    } catch (e) {
      return false;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
} 