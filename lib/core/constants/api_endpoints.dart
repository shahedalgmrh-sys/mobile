class ApiEndpoints {
  static const String health = '/health';
  static const String configFlags = '/config/flags';
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/me';
  static const String profileSetup = '/me/profile-setup';

  // --- Customer (prefix: /c) ---
  static const String home = '/c/home';
  static const String search = '/c/search';
  static String service(String slug) => '/c/services/$slug';
  static String provider(int id) => '/c/providers/$id';

  static const String bookings = '/c/bookings';
  static String booking(int id) => '/c/bookings/$id';
  static String bookingCancel(int id) => '/c/bookings/$id/cancel';
  static String bookingTrack(int id) => '/c/bookings/$id/track';

  static const String reviews = '/c/reviews';
  static const String complaints = '/c/complaints';
  static const String favorites = '/c/favorites';
  static String favoriteToggle(int providerId) => '/c/favorites/$providerId';

  static const String wallet = '/c/wallet';
  static const String walletTopup = '/c/wallet/topup';

  static const String notifications = '/c/notifications';

  static const String chatThreads = '/c/chat/threads';
  static String chatMessages(String threadId) => '/c/chat/threads/$threadId/messages';
  static String chatSend(String threadId) => '/c/chat/threads/$threadId/messages';

  static const String addresses = '/c/addresses';
  static const String preferences = '/c/preferences';
  static const String mediaResumable = '/c/media/resumable';

  // --- Provider (prefix: /p) ---
  static const String pDashboard = '/p/dashboard';
  static const String pAvailabilityToggle = '/p/availability/toggle';

  static const String pRequests = '/p/requests';
  static const String pBookings = '/p/bookings';
  static String pBooking(int id) => '/p/bookings/$id';
  static String providerBookingAccept(int id) => '/p/bookings/$id/accept';
  static String providerBookingReject(int id) => '/p/bookings/$id/reject';
  static String providerBookingStart(int id) => '/p/bookings/$id/start';
  static String providerBookingComplete(int id) => '/p/bookings/$id/complete';
  static String providerBookingUploadProof(int id) => '/p/bookings/$id/upload-proof';

  static const String pEarnings = '/p/earnings';
  static const String pWithdraw = '/p/withdraw';

  static const String pServices = '/p/services';
  static String pServiceToggle(int id) => '/p/services/$id/toggle';

  static const String pKyc = '/p/kyc';
  static String pKycSubmit(String step) => '/p/kyc/$step/submit';

  static const String pCalendar = '/p/calendar';
  static const String pInboxThreads = '/p/inbox/threads';
  static const String pNotifications = '/p/notifications';
}
