import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = 'https://smart-serves.com/api/v1';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Dio get _dio {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    return dio;
  }

  static Future<Map<String, dynamic>> getHome() async {
    final res = await _dio.get('/home');
    return res.data;
  }

  static Future<Map<String, dynamic>> getSettings() async {
    final res = await _dio.get('/settings');
    return res.data;
  }

  static Future<Map<String, dynamic>> getCategories() async {
    final res = await _dio.get('/categories');
    return res.data;
  }

  static Future<Map<String, dynamic>> getProfessions() async {
    final res = await _dio.get('/categories/professions');
    return res.data;
  }

  static Future<Map<String, dynamic>> getBusinesses({String? search, String? category, int page = 1}) async {
    final res = await _dio.get('/businesses', queryParameters: {
      if (search != null) 'search': search,
      if (category != null) 'category': category,
      'page': page,
    });
    return res.data;
  }

  static Future<Map<String, dynamic>> getBusiness(String domain) async {
    final res = await _dio.get('/businesses/$domain');
    return res.data;
  }

  static Future<Map<String, dynamic>> getBusinessReviews(String domain, {int page = 1}) async {
    final res = await _dio.get('/businesses/$domain/reviews', queryParameters: {'page': page});
    return res.data;
  }

  static Future<Map<String, dynamic>> getCraftsmen({String? search, String? profession, String? city, String? sort, int page = 1}) async {
    final res = await _dio.get('/craftsmen', queryParameters: {
      if (search != null) 'search': search,
      if (profession != null) 'profession': profession,
      if (city != null) 'city': city,
      if (sort != null) 'sort': sort,
      'page': page,
    });
    return res.data;
  }

  static Future<Map<String, dynamic>> getCraftsman(String username) async {
    final res = await _dio.get('/craftsmen/$username');
    return res.data;
  }

  static Future<Map<String, dynamic>> getCraftsmanReviews(String username, {int page = 1}) async {
    final res = await _dio.get('/craftsmen/$username/reviews', queryParameters: {'page': page});
    return res.data;
  }

  static Future<Map<String, dynamic>> userLogin(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return res.data;
  }

  static Future<Map<String, dynamic>> userRegister(Map<String, dynamic> data) async {
    final res = await _dio.post('/auth/register', data: data);
    return res.data;
  }

  static Future<Map<String, dynamic>> craftsmanLogin(String email, String password) async {
    final res = await _dio.post('/craftsman/auth/login', data: {'email': email, 'password': password});
    return res.data;
  }

  static Future<Map<String, dynamic>> craftsmanRegister(Map<String, dynamic> data) async {
    final res = await _dio.post('/craftsman/auth/register', data: data);
    return res.data;
  }

  static Future<Map<String, dynamic>> businessLogin(String email, String password) async {
    final res = await _dio.post('/business/auth/login', data: {'email': email, 'password': password});
    return res.data;
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final res = await _dio.get('/user/profile');
    return res.data;
  }

  static Future<Map<String, dynamic>> getCraftsmanDashboard() async {
    final res = await _dio.get('/craftsman/dashboard');
    return res.data;
  }

  static Future<Map<String, dynamic>> getCraftsmanReviewsDashboard() async {
    final res = await _dio.get('/craftsman/reviews');
    return res.data;
  }

  static Future<Map<String, dynamic>> replyCraftsmanReview(int reviewId, String body) async {
    final res = await _dio.post('/craftsman/reviews/$reviewId/reply', data: {'body': body});
    return res.data;
  }

  static Future<Map<String, dynamic>> getBusinessDashboard() async {
    final res = await _dio.get('/business/dashboard');
    return res.data;
  }

  static Future<Map<String, dynamic>> submitCraftsmanReview(String username, int stars, String body, {String? title}) async {
    final res = await _dio.post('/craftsmen/$username/review', data: {
      'stars': stars, 'body': body, if (title != null) 'title': title,
    });
    return res.data;
  }

  static Future<void> saveToken(String token, String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_type', type);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_type');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }
}
