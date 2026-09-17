class ListApi {
  static const String baseUrl = "";
  static const String verifyEmail = "$baseUrl/verify-email?email";
  static const String signIn_sendCode = "$baseUrl/send-code?email";
  static const String signIn = "$baseUrl/login";
  static const String register_client = "$baseUrl/register-user";
  static const String upload_media_verification =
      "$baseUrl/verification/upload";
  static const String get_user = "$baseUrl/user";
  static const String postAnnonce = "$baseUrl/public/api/advertisements";
  static const String add_student = "$baseUrl/student";
  static const String get_student = "$baseUrl/student";
  static const String delete_client = "$baseUrl/student";
  static const String get_rendez_vous = "$baseUrl/appointments";
  static const String delete_rendez_vous = "$baseUrl/appointments";
  static const String add_rendez_vous = "$baseUrl/appointments";
  static const String update_rendez_vous = "$baseUrl/appointments";

  static const String mes_demandes = "$baseUrl/user/advertisements";
  static const String delete_demande = "$baseUrl/advertisements";
  static const String get_demande = "$baseUrl/advertisements";
}