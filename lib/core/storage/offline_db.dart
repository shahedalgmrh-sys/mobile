import 'package:drift/drift.dart';

part 'offline_db.g.dart';

class CachedBookings extends Table {
  IntColumn get id => integer()();
  TextColumn get bookingNumber => text()();
  IntColumn get statusIndex => integer()();
  IntColumn get customerId => integer()();
  IntColumn? get providerId => integer().nullable()();
  IntColumn get serviceId => integer()();
  RealColumn get total => real()();
  TextColumn get currencyCode => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get rawJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedBooking')
class CachedBookingsTable extends CachedBookings {}

class CachedServices extends Table {
  IntColumn get id => integer()();
  TextColumn get slug => text()();
  TextColumn get titleAr => text()();
  TextColumn get titleEn => text()();
  IntColumn get categoryId => integer()();
  RealColumn get basePrice => real()();
  TextColumn get currencyCode => text()();
  IntColumn get durationMinutes => integer()();
  BoolColumn get isActive => boolean()();
  RealColumn get ratingAvg => real().withDefault(const Constant(0.0))();
  IntColumn get reviewsCount => integer().withDefault(const Constant(0))();
  IntColumn? get providerId => integer().nullable()();
  TextColumn get imageUrls => text()();
  TextColumn get rawJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedProviders extends Table {
  IntColumn get userId => integer()();
  TextColumn get businessName => text()();
  RealColumn get ratingAvg => real().withDefault(const Constant(0.0))();
  IntColumn get totalReviews => integer().withDefault(const Constant(0))();
  IntColumn get completedBookings => integer().withDefault(const Constant(0))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  TextColumn? get coverPhoto => text().nullable()();
  TextColumn get serviceAreaCityIds => text()();
  TextColumn get portfolioUrls => text()();
  RealColumn get walletBalance => real().withDefault(const Constant(0.0))();
  RealColumn get totalEarnings => real().withDefault(const Constant(0.0))();
  TextColumn get rawJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get statusIndex => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: const [
  CachedBookings,
  CachedServices,
  CachedProviders,
  SyncQueue,
])
class OfflineDb extends _$OfflineDb {
  OfflineDb(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
