class ApiHelper {
  ApiHelper._();
  static final ApiHelper _instance = ApiHelper._();
  static ApiHelper get instance => _instance;

  Uri getURIParse(String url) {
    return Uri.parse(url);
  }
}
