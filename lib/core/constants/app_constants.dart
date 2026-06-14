class AppConstants {
  // Prefs keys
  static const keyOnboardingCompleted = 'onboarding_completed';
  static const keyDefaultCountdown = 'default_countdown_sec';
  static const keyMorningReminderTime = 'morning_reminder_time';
  static const keyEveningReviewTime = 'evening_review_time';
  static const keyPremiumStatus = 'is_premium';
  static const keyPrivacyMode = 'privacy_mode';
  static const keyStreakCount = 'streak_count';
  static const keyLastStreakDate = 'last_streak_date';
  static const keyRecoveryStreakCount = 'recovery_streak_count';
  static const keyFocusStreakCount = 'focus_streak_count';
  static const keyUserGoal = 'primary_goal';
  static const keyFirstLaunch = 'is_first_launch';

  // Defaults
  static const defaultCountdownSec = 5;
  static const tagline = 'Berhenti sebentar. Pilih dengan sadar.';

  // Commitment statuses
  static const commitmentActive = 'active';
  static const commitmentSuccess = 'success';
  static const commitmentPartial = 'partial';
  static const commitmentMissed = 'missed';

  // Countdown options
  static const countdownOptions = [3, 5, 10, 15, 30, 60];

  // Message tones
  static const messageTones = ['gentle', 'firm', 'strong'];
  static const messageToneLabels = {
    'gentle': 'Lembut',
    'firm': 'Tegas',
    'strong': 'Kuat',
  };

  // Message categories
  static const messageCategories = ['focus', 'health', 'relationship', 'growth', 'custom'];
  static const messageCategoryLabels = {
    'focus': 'Fokus',
    'health': 'Kesehatan',
    'relationship': 'Relasi',
    'growth': 'Pertumbuhan',
    'custom': 'Personal',
  };

  // Goal categories
  static const goalCategories = [
    {'id': 'social_media', 'label': 'Kurangi media sosial', 'icon': '📱'},
    {'id': 'browser', 'label': 'Kurangi browsing tanpa tujuan', 'icon': '🌐'},
    {'id': 'youtube', 'label': 'Kurangi video berlebihan', 'icon': '▶️'},
    {'id': 'games', 'label': 'Kurangi bermain game', 'icon': '🎮'},
    {'id': 'news', 'label': 'Kurangi konsumsi berita negatif', 'icon': '📰'},
    {'id': 'sleep', 'label': 'Perbaiki kualitas tidur', 'icon': '😴'},
    {'id': 'productivity', 'label': 'Tingkatkan produktivitas', 'icon': '🎯'},
    {'id': 'custom', 'label': 'Tujuan lainnya...', 'icon': '✨'},
  ];

  // Triggers for journal
  static const triggers = [
    'Bosan',
    'Stres',
    'Kesepian',
    'Cemas',
    'Lelah',
    'Menghindari tugas',
    'Kebiasaan otomatis',
    'Ingin distraksi',
    'Sosial (teman buka juga)',
    'Lainnya',
  ];

  // Emotions for journal
  static const emotions = [
    'Bosan 😑',
    'Cemas 😰',
    'Stres 😤',
    'Kesepian 😔',
    'Tidak berdaya 😞',
    'Senang 😊',
    'Marah 😠',
    'Sedih 😢',
    'Kelelahan 😴',
    'FOMO 😨',
  ];

  // Built-in quotes (rotating daily)
  static const builtinQuotes = [
    '"Setiap momen adalah pilihan."',
    '"Sadar adalah langkah pertama menuju berubah."',
    '"Kesabaran bukan kelemahan. Ia adalah kekuatan yang terkendali."',
    '"Kamu tidak harus mematuhi setiap dorongan yang datang."',
    '"Versi terbaik dirimu lahir dari pilihan-pilihan kecil."',
    '"Satu jeda, satu napas, satu pilihan lebih baik."',
    '"Scrolling tidak pernah mengisi kekosongan. Hanya memperlambat kamu menghadapinya."',
    '"Bukan soal sempurna. Ini soal konsisten mencoba."',
    '"Setiap hari baru adalah kesempatan baru untuk mulai."',
    '"Jangan menghukum dirimu karena jatuh. Rayakan bahwa kamu bangkit."',
    '"Waktu yang kamu hemat hari ini adalah hadiah untuk dirimu masa depan."',
    '"Kamu lebih kuat dari algoritma yang dirancang untuk menahan perhatianmu."',
    '"Hadir sepenuhnya adalah hadiah paling berharga yang bisa kamu beri."',
    '"Slip bukan gagal. Menyerah adalah gagal."',
    '"Otak yang tenang membuat pilihan yang lebih baik."',
    '"Tidak semua dorongan harus diikuti."',
    '"Apa yang kamu perhatikan itulah yang tumbuh."',
    '"Kamu bukan kebiasaanmu. Kamu pembuat keputusannya."',
    '"Istirahat yang sadar jauh lebih memuaskan daripada scrolling yang tak berujung."',
    '"Konsistensi kecil menghasilkan perubahan besar."',
    '"Satu detik jeda bisa mengubah satu keputusan seumur hidup."',
    '"Setiap kali kamu menutup app itu, kamu menang kecil."',
    '"Hidupmu ada di luar layar itu."',
    '"Kamu boleh berhenti. Kamu boleh mengubah arah."',
    '"Pilih dengan sadar. Hiduplah dengan sengaja."',
    '"Kamu sedang membangun dirimu, satu jeda dalam satu waktu."',
    '"Ada hal lebih baik yang menunggumu di luar layar."',
    '"Kebijaksanaan bukan soal kekuatan menahan. Ini soal memilih dengan sadar."',
    '"Tiap malam yang kamu tidur lebih awal adalah investasi untuk besok."',
    '"Keberanianmu ada di setiap kali kamu memilih untuk berhenti sejenak."',
  ];

  // Default messages to seed
  static const defaultMessages = [
    {'text': 'Apakah ini benar-benar yang ingin kamu lakukan sekarang?', 'category': 'focus', 'tone': 'gentle'},
    {'text': 'Ingat tujuanmu hari ini.', 'category': 'focus', 'tone': 'gentle'},
    {'text': 'Kamu tidak perlu menuruti dorongan ini.', 'category': 'growth', 'tone': 'firm'},
    {'text': 'Tarik napas. Kamu masih punya pilihan.', 'category': 'health', 'tone': 'gentle'},
    {'text': 'Versi terbaik dirimu memilih dengan sadar.', 'category': 'growth', 'tone': 'gentle'},
    {'text': 'Lima menit sekarang atau dua jam terbuang?', 'category': 'focus', 'tone': 'firm'},
    {'text': 'Ada yang lebih penting yang menunggumu.', 'category': 'focus', 'tone': 'gentle'},
    {'text': 'Kamu sudah cukup kuat untuk ini.', 'category': 'growth', 'tone': 'gentle'},
    {'text': 'Waktu yang kamu hemat ini adalah hadiah untuk dirimu.', 'category': 'growth', 'tone': 'gentle'},
    {'text': 'Pilih hadir. Pilih nyata.', 'category': 'relationship', 'tone': 'gentle'},
    {'text': 'Orang-orang yang kamu sayangi lebih berharga dari notifikasi.', 'category': 'relationship', 'tone': 'gentle'},
    {'text': 'Setiap keputusan kecil membentuk kebiasaan besar.', 'category': 'growth', 'tone': 'gentle'},
    {'text': 'Kamu bisa. Kamu sudah pernah berhasil sebelumnya.', 'category': 'growth', 'tone': 'gentle'},
    {'text': 'Tutup ini. Buka yang lebih bermakna.', 'category': 'focus', 'tone': 'firm'},
    {'text': 'Tidurmu lebih penting dari feed ini.', 'category': 'health', 'tone': 'firm'},
  ];
}
