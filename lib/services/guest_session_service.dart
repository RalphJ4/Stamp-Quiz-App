import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class GuestSessionService {
  static const _sessionKey = 'guest_session_id';

  Future<String> getOrCreateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = const Uuid().v4();
    await prefs.setString(_sessionKey, id);
    return id;
  }

  Future<String?> getExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<bool> hasSession() async {
    final id = await getExistingSession();
    return id != null && id.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
