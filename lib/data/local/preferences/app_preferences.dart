import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Onboarding
  Future<bool> get onboardingCompleted async =>
      (await prefs).getBool(AppConstants.keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool v) async =>
      (await prefs).setBool(AppConstants.keyOnboardingCompleted, v);

  // Default countdown
  Future<int> get defaultCountdown async =>
      (await prefs).getInt(AppConstants.keyDefaultCountdown) ?? AppConstants.defaultCountdownSec;
  Future<void> setDefaultCountdown(int v) async =>
      (await prefs).setInt(AppConstants.keyDefaultCountdown, v);

  // Morning reminder time (HH:mm string)
  Future<String?> get morningReminderTime async =>
      (await prefs).getString(AppConstants.keyMorningReminderTime);
  Future<void> setMorningReminderTime(String v) async =>
      (await prefs).setString(AppConstants.keyMorningReminderTime, v);

  // Evening review time
  Future<String?> get eveningReviewTime async =>
      (await prefs).getString(AppConstants.keyEveningReviewTime);
  Future<void> setEveningReviewTime(String v) async =>
      (await prefs).setString(AppConstants.keyEveningReviewTime, v);

  // Premium
  Future<bool> get isPremium async =>
      (await prefs).getBool(AppConstants.keyPremiumStatus) ?? false;
  Future<void> setPremium(bool v) async =>
      (await prefs).setBool(AppConstants.keyPremiumStatus, v);

  // Privacy mode
  Future<bool> get privacyMode async =>
      (await prefs).getBool(AppConstants.keyPrivacyMode) ?? false;
  Future<void> setPrivacyMode(bool v) async =>
      (await prefs).setBool(AppConstants.keyPrivacyMode, v);

  // Streak
  Future<int> get streakCount async =>
      (await prefs).getInt(AppConstants.keyStreakCount) ?? 0;
  Future<void> setStreakCount(int v) async =>
      (await prefs).setInt(AppConstants.keyStreakCount, v);

  Future<String?> get lastStreakDate async =>
      (await prefs).getString(AppConstants.keyLastStreakDate);
  Future<void> setLastStreakDate(String v) async =>
      (await prefs).setString(AppConstants.keyLastStreakDate, v);

  Future<int> get recoveryStreakCount async =>
      (await prefs).getInt(AppConstants.keyRecoveryStreakCount) ?? 0;
  Future<void> setRecoveryStreakCount(int v) async =>
      (await prefs).setInt(AppConstants.keyRecoveryStreakCount, v);

  Future<int> get focusStreakCount async =>
      (await prefs).getInt(AppConstants.keyFocusStreakCount) ?? 0;
  Future<void> setFocusStreakCount(int v) async =>
      (await prefs).setInt(AppConstants.keyFocusStreakCount, v);

  // User goal
  Future<String?> get primaryGoal async =>
      (await prefs).getString(AppConstants.keyUserGoal);
  Future<void> setPrimaryGoal(String v) async =>
      (await prefs).setString(AppConstants.keyUserGoal, v);

  // Life goal text
  Future<String?> get lifeGoalText async =>
      (await prefs).getString('life_goal_text');
  Future<void> setLifeGoalText(String v) async =>
      (await prefs).setString('life_goal_text', v);

  Future<bool> get showGoalInPopup async =>
      (await prefs).getBool('show_goal_in_popup') ?? true;
  Future<void> setShowGoalInPopup(bool v) async =>
      (await prefs).setBool('show_goal_in_popup', v);

  // Service enabled
  Future<bool> get serviceEnabled async =>
      (await prefs).getBool('service_enabled') ?? true;
  Future<void> setServiceEnabled(bool v) async =>
      (await prefs).setBool('service_enabled', v);

  // First launch
  Future<bool> get isFirstLaunch async =>
      (await prefs).getBool(AppConstants.keyFirstLaunch) ?? true;
  Future<void> setFirstLaunch(bool v) async =>
      (await prefs).setBool(AppConstants.keyFirstLaunch, v);

  // Quote of day index
  Future<int> get quoteIndex async =>
      (await prefs).getInt('quote_index') ?? 0;
  Future<void> setQuoteIndex(int v) async =>
      (await prefs).setInt('quote_index', v);

  // Last quote date
  Future<String?> get lastQuoteDate async =>
      (await prefs).getString('last_quote_date');
  Future<void> setLastQuoteDate(String v) async =>
      (await prefs).setString('last_quote_date', v);

  Future<void> clear() async => (await prefs).clear();
}
