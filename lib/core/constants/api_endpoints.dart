/// API endpoints matching the Laravel backend routes (routes/api.php).
/// Base URL is configured via AppConfig.apiBaseUrl (e.g. http://host/api).
class ApiEndpoints {
  ApiEndpoints._();

  // --- Public ---
  static const String health = '/health';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String services = '/services';
  static const String providers = '/providers';
  static String providerProfile(String id) => '/providers/$id';
  static const String offers = '/offers';
  static const String cities = '/cities';
  static String cityAreas(String cityId) => '/cities/$cityId/areas';
  static const String faqs = '/faqs';
  static const String ads = '/ads';
  static const String blogs = '/blogs';
  static String showBlog(String slug) => '/blogs/$slug';
  static String blogComments(String id) => '/blogs/$id/comments';
  static String contentPage(String slug) => '/pages/$slug';
  static const String contact = '/contact';
  static const String currencies = '/currencies';

  // --- Auth (/auth) ---
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String authUser = '/auth/user';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // --- Customer (/customer) ---
  static const String customerMe = '/customer/me';
  static const String customerPassword = '/customer/me/password';
  static const String customerAvatar = '/customer/me/avatar';
  static const String customerPreferences = '/customer/me/preferences';
  static const String customerAddresses = '/customer/addresses';
  static String customerAddress(String id) => '/customer/addresses/$id';

  static const String customerBookings = '/customer/bookings';
  static const String bookingAvailableSlots = '/customer/bookings/available-slots';
  static String customerBooking(String id) => '/customer/bookings/$id';
  static String bookingTrack(String id) => '/customer/bookings/$id/track';
  static String bookingCancel(String id) => '/customer/bookings/$id/cancel';
  static String bookingReschedule(String id) => '/customer/bookings/$id/reschedule';
  static String bookingRebook(String id) => '/customer/bookings/$id/rebook';
  static String bookingPay(String id) => '/customer/bookings/$id/pay';

  static const String customerPayments = '/customer/payments';
  static String payment(String id) => '/customer/payments/$id';
  static String paymentInvoice(String id) => '/customer/payments/$id/invoice';

  static const String customerWallet = '/customer/wallet';
  static const String walletTransactions = '/customer/wallet/transactions';
  static const String walletAddFunds = '/customer/wallet/add-funds';
  static String walletConfirmPayment(String paymentId) =>
      '/customer/wallet/confirm-payment/$paymentId';

  static const String customerFavorites = '/customer/favorites';
  static const String favoriteToggle = '/customer/favorites/toggle';
  static String favoriteProviderToggle(String id) => '/customer/favorites/providers/$id/toggle';

  static const String customerReviews = '/customer/reviews';
  static const String customerComplaints = '/customer/complaints';

  static const String customerConversations = '/customer/conversations';
  static String conversation(String id) => '/customer/conversations/$id';
  static String conversationMessages(String id) => '/customer/conversations/$id/messages';

  static const String customerNotifications = '/customer/notifications';
  static const String notificationsUnread = '/customer/notifications/unread';
  static String notificationRead(String id) => '/customer/notifications/$id/read';

  static const String customerCoupons = '/customer/coupons';
  static const String couponValidate = '/customer/coupons/validate';
  static const String customerSearch = '/customer/search';
  static const String searchPopular = '/customer/search/popular';
  static String customerReport(String type) => '/customer/reports/$type';

  // --- Provider (/provider) ---
  static const String providerDashboard = '/provider/dashboard';
  static const String providerProfileMe = '/provider/profile';
  static const String providerPassword = '/provider/profile/password';
  static const String providerLogo = '/provider/profile/logo';
  static String providerAvatarDestroy = '/provider/profile/avatar';
  static String providerLogoDestroy = '/provider/profile/logo';
  static String providerCoverDestroy = '/provider/profile/cover';
  static const String providerVerificationStatus = '/provider/verification-status';
  static const String providerVerification = '/provider/verification';

  static const String providerServices = '/provider/services';
  static String providerService(String id) => '/provider/services/$id';
  static String serviceToggleActive(String id) => '/provider/services/$id/toggle-active';
  static String serviceToggleAvailable(String id) =>
      '/provider/services/$id/toggle-available';
  static String serviceDuplicate(String id) => '/provider/services/$id/duplicate';

  static const String providerBookings = '/provider/bookings';
  static String providerBooking(String id) => '/provider/bookings/$id';
  static String bookingAccept(String id) => '/provider/bookings/$id/accept';
  static String bookingReject(String id) => '/provider/bookings/$id/reject';
  static String bookingStart(String id) => '/provider/bookings/$id/start';
  static String bookingComplete(String id) => '/provider/bookings/$id/complete';
  static String providerBookingCancel(String id) => '/provider/bookings/$id/cancel';
  static String providerBookingReschedule(String id) => '/provider/bookings/$id/reschedule';

  static const String providerAvailability = '/provider/availability';
  static const String workingHours = '/provider/availability/working-hours';
  static String workingHour(String id) => '/provider/availability/working-hours/$id';
  static const String availabilityAreas = '/provider/availability/areas';
  static String availabilityArea(String id) => '/provider/availability/areas/$id';

  static const String providerPortfolio = '/provider/portfolio';
  static String portfolioItem(String id) => '/provider/portfolio/$id';

  static const String providerWallet = '/provider/wallet';
  static const String providerWithdrawals = '/provider/withdrawals';
  static String withdrawalCancel(String id) => '/provider/withdrawals/$id/cancel';

  static const String providerReviews = '/provider/reviews';
  static String reviewReply(String id) => '/provider/reviews/$id/reply';

  static const String providerConversations = '/provider/conversations';
  static String providerConversation(String id) => '/provider/conversations/$id';
  static String providerConversationMessages(String id) => '/provider/conversations/$id/messages';

  static const String providerNotifications = '/provider/notifications';
  static String providerNotificationRead(String id) => '/provider/notifications/$id/read';
  static const String providerNotificationsReadAll = '/provider/notifications/read-all';

  static const String providerRequests = '/provider/requests';
  static String providerRequest(String id) => '/provider/requests/$id';
  static String requestAccept(String id) => '/provider/requests/$id/accept';
  static String requestReject(String id) => '/provider/requests/$id/reject';
  static String requestComplete(String id) => '/provider/requests/$id/complete';

  static const String reportBookings = '/provider/reports/bookings';
  static const String reportRevenue = '/provider/reports/revenue';
}
