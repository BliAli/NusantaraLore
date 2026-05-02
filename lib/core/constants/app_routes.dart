class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const biometric = '/biometric';
  static const home = '/home';
  static const explore = '/home/explore';
  static const budayaDetail = '/home/explore/:id';
  static const map = '/home/map';
  static const games = '/home/games';
  static const kuisMitos = '/home/games/kuis';
  static const puzzleBatik = '/home/games/puzzle';
  static const tebakWayang = '/home/games/wayang';
  static const leaderboard = '/home/games/leaderboard';
  static const penjaga = '/home/penjaga';
  static const converter = '/home/converter';
  static const search = '/home/search';
  static const profile = '/home/profile';
  static const bookmark = '/home/profile/bookmark';
  static const quizHistory = '/home/profile/quiz-history';
  static const editProfile = '/home/profile/edit';

  static String budayaDetailPath(String id) => '/home/explore/$id';
}
