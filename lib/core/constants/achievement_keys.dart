class AchievementKeys {
  // Streak milestones
  static const firstPause = 'first_pause';
  static const firstBetterChoice = 'first_better_choice';
  static const streak3 = 'streak_3';
  static const streak7 = 'streak_7';
  static const streak14 = 'streak_14';
  static const streak30 = 'streak_30';
  static const streak60 = 'streak_60';
  static const streak90 = 'streak_90';

  // Behavior
  static const nightShield = 'night_shield';
  static const patternFinder = 'pattern_finder';
  static const focusChampion = 'focus_champion';
  static const commitmentKeeper = 'commitment_keeper';
  static const honestReflection = 'honest_reflection';

  static const List<Map<String, dynamic>> allAchievements = [
    {
      'id': firstPause,
      'title': 'Jeda Pertama',
      'description': 'Kamu mengalami jeda pertamamu. Ini awalnya.',
      'icon': '⏸️',
      'target': 1,
    },
    {
      'id': firstBetterChoice,
      'title': 'Pilihan Lebih Baik',
      'description': 'Pertama kali kamu memilih untuk tidak membuka app pemicu.',
      'icon': '✅',
      'target': 1,
    },
    {
      'id': streak3,
      'title': '3 Hari Konsisten',
      'description': 'Bertahan 3 hari berturut-turut. Awal yang baik!',
      'icon': '🌱',
      'target': 1,
    },
    {
      'id': streak7,
      'title': 'Satu Minggu Penuh',
      'description': '7 hari berturut-turut. Kamu membangun kebiasaan.',
      'icon': '🔥',
      'target': 1,
    },
    {
      'id': streak14,
      'title': 'Dua Minggu Kuat',
      'description': '14 hari konsisten. Otak mulai beradaptasi.',
      'icon': '⚡',
      'target': 1,
    },
    {
      'id': streak30,
      'title': 'Satu Bulan Sadar',
      'description': '30 hari berturut-turut. Kebiasaan baru terbentuk.',
      'icon': '🏆',
      'target': 1,
    },
    {
      'id': streak60,
      'title': 'Dua Bulan Bertahan',
      'description': '60 hari! Ini bukan lagi eksperimen — ini gaya hidupmu.',
      'icon': '💎',
      'target': 1,
    },
    {
      'id': streak90,
      'title': 'Tiga Bulan Maestro',
      'description': '90 hari. Kamu telah membangun ulang dirimu.',
      'icon': '👑',
      'target': 1,
    },
    {
      'id': nightShield,
      'title': 'Penjaga Malam',
      'description': 'Berhasil menahan diri di jam rawan (22:00–02:00) sebanyak 10 kali.',
      'icon': '🌙',
      'target': 10,
    },
    {
      'id': patternFinder,
      'title': 'Pemahaman Diri',
      'description': 'Menulis 5 entri jurnal. Kamu mengenali polamu.',
      'icon': '🔍',
      'target': 5,
    },
    {
      'id': focusChampion,
      'title': 'Juara Fokus',
      'description': 'Menyelesaikan 10 sesi Focus Mode.',
      'icon': '🎯',
      'target': 10,
    },
    {
      'id': commitmentKeeper,
      'title': 'Penjaga Janji',
      'description': 'Berhasil menyelesaikan 20 komitmen harian.',
      'icon': '🤝',
      'target': 20,
    },
    {
      'id': honestReflection,
      'title': 'Kejujuran Diri',
      'description': 'Mencatat slip pertama dengan jujur. Keberanian sejati.',
      'icon': '💪',
      'target': 1,
    },
  ];
}
