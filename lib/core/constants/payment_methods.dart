/// Booking/top-up payment methods.
///
/// Keep in sync with the server whitelist:
/// `in:stripe,paypal,apple_pay,google_pay,mada,stc_pay,cash,wallet`
/// (`CustomerApiController@payBooking` / `@addFunds`).
class PaymentMethods {
  const PaymentMethods._();

  static const (String code, String label, String hint) wallet =
      ('wallet', 'محفظة المنصة', 'خصم فوري من رصيدك');
  static const (String code, String label, String hint) cash =
      ('cash', 'كاش عند الاستلام', 'الدفع نقداً للمزوّد');
  static const (String code, String label, String hint) mada =
      ('mada', 'مدى', 'بطاقة سعودية');
  static const (String code, String label, String hint) stcPay =
      ('stc_pay', 'STC Pay', 'محفظة سعودية');
  static const (String code, String label, String hint) applePay =
      ('apple_pay', 'Apple Pay', 'الأجهزة الآيفون');
  static const (String code, String label, String hint) googlePay =
      ('google_pay', 'Google Pay', 'الأجهزة الأندرويد');
  static const (String code, String label, String hint) card =
      ('stripe', 'بطاقة (Visa/Master)', 'شبكة عالمية');
  static const (String code, String label, String hint) paypal =
      ('paypal', 'PayPal', 'محفظة إلكترونية');

  /// All methods accepted by `/customer/bookings/{id}/pay`.
  static const List<(String code, String label, String hint)> booking =
      [wallet, cash, mada, stcPay, applePay, googlePay, card, paypal];

  /// Methods accepted by `/customer/wallet/add-funds` (no cash/wallet).
  static const List<(String code, String label, String hint)> topUp =
      [mada, stcPay, applePay, googlePay, card, paypal];
}
