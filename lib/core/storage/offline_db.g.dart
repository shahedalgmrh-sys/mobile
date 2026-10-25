// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_db.dart';

// ignore_for_file: type=lint
class $CachedBookingsTable extends CachedBookings
    with TableInfo<$CachedBookingsTable, CachedBooking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedBookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bookingNumberMeta =
      const VerificationMeta('bookingNumber');
  @override
  late final GeneratedColumn<String> bookingNumber = GeneratedColumn<String>(
      'booking_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusIndexMeta =
      const VerificationMeta('statusIndex');
  @override
  late final GeneratedColumn<int> statusIndex = GeneratedColumn<int>(
      'status_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<int> providerId = GeneratedColumn<int>(
      'provider_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _serviceIdMeta =
      const VerificationMeta('serviceId');
  @override
  late final GeneratedColumn<int> serviceId = GeneratedColumn<int>(
      'service_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookingNumber,
        statusIndex,
        customerId,
        providerId,
        serviceId,
        total,
        currencyCode,
        scheduledAt,
        rawJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_bookings';
  @override
  VerificationContext validateIntegrity(Insertable<CachedBooking> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('booking_number')) {
      context.handle(
          _bookingNumberMeta,
          bookingNumber.isAcceptableOrUnknown(
              data['booking_number']!, _bookingNumberMeta));
    } else if (isInserting) {
      context.missing(_bookingNumberMeta);
    }
    if (data.containsKey('status_index')) {
      context.handle(
          _statusIndexMeta,
          statusIndex.isAcceptableOrUnknown(
              data['status_index']!, _statusIndexMeta));
    } else if (isInserting) {
      context.missing(_statusIndexMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    }
    if (data.containsKey('service_id')) {
      context.handle(_serviceIdMeta,
          serviceId.isAcceptableOrUnknown(data['service_id']!, _serviceIdMeta));
    } else if (isInserting) {
      context.missing(_serviceIdMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedBooking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedBooking(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookingNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}booking_number'])!,
      statusIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status_index'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider_id']),
      serviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}service_id'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedBookingsTable createAlias(String alias) {
    return $CachedBookingsTable(attachedDatabase, alias);
  }
}

class CachedBooking extends DataClass implements Insertable<CachedBooking> {
  final int id;
  final String bookingNumber;
  final int statusIndex;
  final int customerId;
  final int? providerId;
  final int serviceId;
  final double total;
  final String currencyCode;
  final DateTime? scheduledAt;
  final String rawJson;
  final DateTime updatedAt;
  const CachedBooking(
      {required this.id,
      required this.bookingNumber,
      required this.statusIndex,
      required this.customerId,
      this.providerId,
      required this.serviceId,
      required this.total,
      required this.currencyCode,
      this.scheduledAt,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['booking_number'] = Variable<String>(bookingNumber);
    map['status_index'] = Variable<int>(statusIndex);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<int>(providerId);
    }
    map['service_id'] = Variable<int>(serviceId);
    map['total'] = Variable<double>(total);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedBookingsCompanion toCompanion(bool nullToAbsent) {
    return CachedBookingsCompanion(
      id: Value(id),
      bookingNumber: Value(bookingNumber),
      statusIndex: Value(statusIndex),
      customerId: Value(customerId),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      serviceId: Value(serviceId),
      total: Value(total),
      currencyCode: Value(currencyCode),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedBooking.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedBooking(
      id: serializer.fromJson<int>(json['id']),
      bookingNumber: serializer.fromJson<String>(json['bookingNumber']),
      statusIndex: serializer.fromJson<int>(json['statusIndex']),
      customerId: serializer.fromJson<int>(json['customerId']),
      providerId: serializer.fromJson<int?>(json['providerId']),
      serviceId: serializer.fromJson<int>(json['serviceId']),
      total: serializer.fromJson<double>(json['total']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookingNumber': serializer.toJson<String>(bookingNumber),
      'statusIndex': serializer.toJson<int>(statusIndex),
      'customerId': serializer.toJson<int>(customerId),
      'providerId': serializer.toJson<int?>(providerId),
      'serviceId': serializer.toJson<int>(serviceId),
      'total': serializer.toJson<double>(total),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedBooking copyWith(
          {int? id,
          String? bookingNumber,
          int? statusIndex,
          int? customerId,
          Value<int?> providerId = const Value.absent(),
          int? serviceId,
          double? total,
          String? currencyCode,
          Value<DateTime?> scheduledAt = const Value.absent(),
          String? rawJson,
          DateTime? updatedAt}) =>
      CachedBooking(
        id: id ?? this.id,
        bookingNumber: bookingNumber ?? this.bookingNumber,
        statusIndex: statusIndex ?? this.statusIndex,
        customerId: customerId ?? this.customerId,
        providerId: providerId.present ? providerId.value : this.providerId,
        serviceId: serviceId ?? this.serviceId,
        total: total ?? this.total,
        currencyCode: currencyCode ?? this.currencyCode,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedBooking copyWithCompanion(CachedBookingsCompanion data) {
    return CachedBooking(
      id: data.id.present ? data.id.value : this.id,
      bookingNumber: data.bookingNumber.present
          ? data.bookingNumber.value
          : this.bookingNumber,
      statusIndex:
          data.statusIndex.present ? data.statusIndex.value : this.statusIndex,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      serviceId: data.serviceId.present ? data.serviceId.value : this.serviceId,
      total: data.total.present ? data.total.value : this.total,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedBooking(')
          ..write('id: $id, ')
          ..write('bookingNumber: $bookingNumber, ')
          ..write('statusIndex: $statusIndex, ')
          ..write('customerId: $customerId, ')
          ..write('providerId: $providerId, ')
          ..write('serviceId: $serviceId, ')
          ..write('total: $total, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookingNumber,
      statusIndex,
      customerId,
      providerId,
      serviceId,
      total,
      currencyCode,
      scheduledAt,
      rawJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedBooking &&
          other.id == this.id &&
          other.bookingNumber == this.bookingNumber &&
          other.statusIndex == this.statusIndex &&
          other.customerId == this.customerId &&
          other.providerId == this.providerId &&
          other.serviceId == this.serviceId &&
          other.total == this.total &&
          other.currencyCode == this.currencyCode &&
          other.scheduledAt == this.scheduledAt &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class CachedBookingsCompanion extends UpdateCompanion<CachedBooking> {
  final Value<int> id;
  final Value<String> bookingNumber;
  final Value<int> statusIndex;
  final Value<int> customerId;
  final Value<int?> providerId;
  final Value<int> serviceId;
  final Value<double> total;
  final Value<String> currencyCode;
  final Value<DateTime?> scheduledAt;
  final Value<String> rawJson;
  final Value<DateTime> updatedAt;
  const CachedBookingsCompanion({
    this.id = const Value.absent(),
    this.bookingNumber = const Value.absent(),
    this.statusIndex = const Value.absent(),
    this.customerId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.serviceId = const Value.absent(),
    this.total = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedBookingsCompanion.insert({
    this.id = const Value.absent(),
    required String bookingNumber,
    required int statusIndex,
    required int customerId,
    this.providerId = const Value.absent(),
    required int serviceId,
    required double total,
    required String currencyCode,
    this.scheduledAt = const Value.absent(),
    required String rawJson,
    required DateTime updatedAt,
  })  : bookingNumber = Value(bookingNumber),
        statusIndex = Value(statusIndex),
        customerId = Value(customerId),
        serviceId = Value(serviceId),
        total = Value(total),
        currencyCode = Value(currencyCode),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<CachedBooking> custom({
    Expression<int>? id,
    Expression<String>? bookingNumber,
    Expression<int>? statusIndex,
    Expression<int>? customerId,
    Expression<int>? providerId,
    Expression<int>? serviceId,
    Expression<double>? total,
    Expression<String>? currencyCode,
    Expression<DateTime>? scheduledAt,
    Expression<String>? rawJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookingNumber != null) 'booking_number': bookingNumber,
      if (statusIndex != null) 'status_index': statusIndex,
      if (customerId != null) 'customer_id': customerId,
      if (providerId != null) 'provider_id': providerId,
      if (serviceId != null) 'service_id': serviceId,
      if (total != null) 'total': total,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedBookingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? bookingNumber,
      Value<int>? statusIndex,
      Value<int>? customerId,
      Value<int?>? providerId,
      Value<int>? serviceId,
      Value<double>? total,
      Value<String>? currencyCode,
      Value<DateTime?>? scheduledAt,
      Value<String>? rawJson,
      Value<DateTime>? updatedAt}) {
    return CachedBookingsCompanion(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      statusIndex: statusIndex ?? this.statusIndex,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      total: total ?? this.total,
      currencyCode: currencyCode ?? this.currencyCode,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookingNumber.present) {
      map['booking_number'] = Variable<String>(bookingNumber.value);
    }
    if (statusIndex.present) {
      map['status_index'] = Variable<int>(statusIndex.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<int>(providerId.value);
    }
    if (serviceId.present) {
      map['service_id'] = Variable<int>(serviceId.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedBookingsCompanion(')
          ..write('id: $id, ')
          ..write('bookingNumber: $bookingNumber, ')
          ..write('statusIndex: $statusIndex, ')
          ..write('customerId: $customerId, ')
          ..write('providerId: $providerId, ')
          ..write('serviceId: $serviceId, ')
          ..write('total: $total, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedServicesTable extends CachedServices
    with TableInfo<$CachedServicesTable, CachedService> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedServicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleArMeta =
      const VerificationMeta('titleAr');
  @override
  late final GeneratedColumn<String> titleAr = GeneratedColumn<String>(
      'title_ar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleEnMeta =
      const VerificationMeta('titleEn');
  @override
  late final GeneratedColumn<String> titleEn = GeneratedColumn<String>(
      'title_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _basePriceMeta =
      const VerificationMeta('basePrice');
  @override
  late final GeneratedColumn<double> basePrice = GeneratedColumn<double>(
      'base_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  static const VerificationMeta _ratingAvgMeta =
      const VerificationMeta('ratingAvg');
  @override
  late final GeneratedColumn<double> ratingAvg = GeneratedColumn<double>(
      'rating_avg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _reviewsCountMeta =
      const VerificationMeta('reviewsCount');
  @override
  late final GeneratedColumn<int> reviewsCount = GeneratedColumn<int>(
      'reviews_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<int> providerId = GeneratedColumn<int>(
      'provider_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlsMeta =
      const VerificationMeta('imageUrls');
  @override
  late final GeneratedColumn<String> imageUrls = GeneratedColumn<String>(
      'image_urls', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        slug,
        titleAr,
        titleEn,
        categoryId,
        basePrice,
        currencyCode,
        durationMinutes,
        isActive,
        ratingAvg,
        reviewsCount,
        providerId,
        imageUrls,
        rawJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_services';
  @override
  VerificationContext validateIntegrity(Insertable<CachedService> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title_ar')) {
      context.handle(_titleArMeta,
          titleAr.isAcceptableOrUnknown(data['title_ar']!, _titleArMeta));
    } else if (isInserting) {
      context.missing(_titleArMeta);
    }
    if (data.containsKey('title_en')) {
      context.handle(_titleEnMeta,
          titleEn.isAcceptableOrUnknown(data['title_en']!, _titleEnMeta));
    } else if (isInserting) {
      context.missing(_titleEnMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('base_price')) {
      context.handle(_basePriceMeta,
          basePrice.isAcceptableOrUnknown(data['base_price']!, _basePriceMeta));
    } else if (isInserting) {
      context.missing(_basePriceMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('rating_avg')) {
      context.handle(_ratingAvgMeta,
          ratingAvg.isAcceptableOrUnknown(data['rating_avg']!, _ratingAvgMeta));
    }
    if (data.containsKey('reviews_count')) {
      context.handle(
          _reviewsCountMeta,
          reviewsCount.isAcceptableOrUnknown(
              data['reviews_count']!, _reviewsCountMeta));
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    }
    if (data.containsKey('image_urls')) {
      context.handle(_imageUrlsMeta,
          imageUrls.isAcceptableOrUnknown(data['image_urls']!, _imageUrlsMeta));
    } else if (isInserting) {
      context.missing(_imageUrlsMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedService map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedService(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      titleAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_ar'])!,
      titleEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_en'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      basePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_price'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      ratingAvg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating_avg'])!,
      reviewsCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reviews_count'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}provider_id']),
      imageUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_urls'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedServicesTable createAlias(String alias) {
    return $CachedServicesTable(attachedDatabase, alias);
  }
}

class CachedService extends DataClass implements Insertable<CachedService> {
  final int id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final int categoryId;
  final double basePrice;
  final String currencyCode;
  final int durationMinutes;
  final bool isActive;
  final double ratingAvg;
  final int reviewsCount;
  final int? providerId;
  final String imageUrls;
  final String rawJson;
  final DateTime updatedAt;
  const CachedService(
      {required this.id,
      required this.slug,
      required this.titleAr,
      required this.titleEn,
      required this.categoryId,
      required this.basePrice,
      required this.currencyCode,
      required this.durationMinutes,
      required this.isActive,
      required this.ratingAvg,
      required this.reviewsCount,
      this.providerId,
      required this.imageUrls,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['slug'] = Variable<String>(slug);
    map['title_ar'] = Variable<String>(titleAr);
    map['title_en'] = Variable<String>(titleEn);
    map['category_id'] = Variable<int>(categoryId);
    map['base_price'] = Variable<double>(basePrice);
    map['currency_code'] = Variable<String>(currencyCode);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['is_active'] = Variable<bool>(isActive);
    map['rating_avg'] = Variable<double>(ratingAvg);
    map['reviews_count'] = Variable<int>(reviewsCount);
    if (!nullToAbsent || providerId != null) {
      map['provider_id'] = Variable<int>(providerId);
    }
    map['image_urls'] = Variable<String>(imageUrls);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedServicesCompanion toCompanion(bool nullToAbsent) {
    return CachedServicesCompanion(
      id: Value(id),
      slug: Value(slug),
      titleAr: Value(titleAr),
      titleEn: Value(titleEn),
      categoryId: Value(categoryId),
      basePrice: Value(basePrice),
      currencyCode: Value(currencyCode),
      durationMinutes: Value(durationMinutes),
      isActive: Value(isActive),
      ratingAvg: Value(ratingAvg),
      reviewsCount: Value(reviewsCount),
      providerId: providerId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerId),
      imageUrls: Value(imageUrls),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedService.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedService(
      id: serializer.fromJson<int>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      titleAr: serializer.fromJson<String>(json['titleAr']),
      titleEn: serializer.fromJson<String>(json['titleEn']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      basePrice: serializer.fromJson<double>(json['basePrice']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      ratingAvg: serializer.fromJson<double>(json['ratingAvg']),
      reviewsCount: serializer.fromJson<int>(json['reviewsCount']),
      providerId: serializer.fromJson<int?>(json['providerId']),
      imageUrls: serializer.fromJson<String>(json['imageUrls']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'slug': serializer.toJson<String>(slug),
      'titleAr': serializer.toJson<String>(titleAr),
      'titleEn': serializer.toJson<String>(titleEn),
      'categoryId': serializer.toJson<int>(categoryId),
      'basePrice': serializer.toJson<double>(basePrice),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'ratingAvg': serializer.toJson<double>(ratingAvg),
      'reviewsCount': serializer.toJson<int>(reviewsCount),
      'providerId': serializer.toJson<int?>(providerId),
      'imageUrls': serializer.toJson<String>(imageUrls),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedService copyWith(
          {int? id,
          String? slug,
          String? titleAr,
          String? titleEn,
          int? categoryId,
          double? basePrice,
          String? currencyCode,
          int? durationMinutes,
          bool? isActive,
          double? ratingAvg,
          int? reviewsCount,
          Value<int?> providerId = const Value.absent(),
          String? imageUrls,
          String? rawJson,
          DateTime? updatedAt}) =>
      CachedService(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        titleAr: titleAr ?? this.titleAr,
        titleEn: titleEn ?? this.titleEn,
        categoryId: categoryId ?? this.categoryId,
        basePrice: basePrice ?? this.basePrice,
        currencyCode: currencyCode ?? this.currencyCode,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        isActive: isActive ?? this.isActive,
        ratingAvg: ratingAvg ?? this.ratingAvg,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        providerId: providerId.present ? providerId.value : this.providerId,
        imageUrls: imageUrls ?? this.imageUrls,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedService copyWithCompanion(CachedServicesCompanion data) {
    return CachedService(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      titleAr: data.titleAr.present ? data.titleAr.value : this.titleAr,
      titleEn: data.titleEn.present ? data.titleEn.value : this.titleEn,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      basePrice: data.basePrice.present ? data.basePrice.value : this.basePrice,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      ratingAvg: data.ratingAvg.present ? data.ratingAvg.value : this.ratingAvg,
      reviewsCount: data.reviewsCount.present
          ? data.reviewsCount.value
          : this.reviewsCount,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      imageUrls: data.imageUrls.present ? data.imageUrls.value : this.imageUrls,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedService(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('titleAr: $titleAr, ')
          ..write('titleEn: $titleEn, ')
          ..write('categoryId: $categoryId, ')
          ..write('basePrice: $basePrice, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('ratingAvg: $ratingAvg, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('providerId: $providerId, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      slug,
      titleAr,
      titleEn,
      categoryId,
      basePrice,
      currencyCode,
      durationMinutes,
      isActive,
      ratingAvg,
      reviewsCount,
      providerId,
      imageUrls,
      rawJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedService &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.titleAr == this.titleAr &&
          other.titleEn == this.titleEn &&
          other.categoryId == this.categoryId &&
          other.basePrice == this.basePrice &&
          other.currencyCode == this.currencyCode &&
          other.durationMinutes == this.durationMinutes &&
          other.isActive == this.isActive &&
          other.ratingAvg == this.ratingAvg &&
          other.reviewsCount == this.reviewsCount &&
          other.providerId == this.providerId &&
          other.imageUrls == this.imageUrls &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class CachedServicesCompanion extends UpdateCompanion<CachedService> {
  final Value<int> id;
  final Value<String> slug;
  final Value<String> titleAr;
  final Value<String> titleEn;
  final Value<int> categoryId;
  final Value<double> basePrice;
  final Value<String> currencyCode;
  final Value<int> durationMinutes;
  final Value<bool> isActive;
  final Value<double> ratingAvg;
  final Value<int> reviewsCount;
  final Value<int?> providerId;
  final Value<String> imageUrls;
  final Value<String> rawJson;
  final Value<DateTime> updatedAt;
  const CachedServicesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.titleAr = const Value.absent(),
    this.titleEn = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.basePrice = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.ratingAvg = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    this.providerId = const Value.absent(),
    this.imageUrls = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedServicesCompanion.insert({
    this.id = const Value.absent(),
    required String slug,
    required String titleAr,
    required String titleEn,
    required int categoryId,
    required double basePrice,
    required String currencyCode,
    required int durationMinutes,
    required bool isActive,
    this.ratingAvg = const Value.absent(),
    this.reviewsCount = const Value.absent(),
    this.providerId = const Value.absent(),
    required String imageUrls,
    required String rawJson,
    required DateTime updatedAt,
  })  : slug = Value(slug),
        titleAr = Value(titleAr),
        titleEn = Value(titleEn),
        categoryId = Value(categoryId),
        basePrice = Value(basePrice),
        currencyCode = Value(currencyCode),
        durationMinutes = Value(durationMinutes),
        isActive = Value(isActive),
        imageUrls = Value(imageUrls),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<CachedService> custom({
    Expression<int>? id,
    Expression<String>? slug,
    Expression<String>? titleAr,
    Expression<String>? titleEn,
    Expression<int>? categoryId,
    Expression<double>? basePrice,
    Expression<String>? currencyCode,
    Expression<int>? durationMinutes,
    Expression<bool>? isActive,
    Expression<double>? ratingAvg,
    Expression<int>? reviewsCount,
    Expression<int>? providerId,
    Expression<String>? imageUrls,
    Expression<String>? rawJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (titleAr != null) 'title_ar': titleAr,
      if (titleEn != null) 'title_en': titleEn,
      if (categoryId != null) 'category_id': categoryId,
      if (basePrice != null) 'base_price': basePrice,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (isActive != null) 'is_active': isActive,
      if (ratingAvg != null) 'rating_avg': ratingAvg,
      if (reviewsCount != null) 'reviews_count': reviewsCount,
      if (providerId != null) 'provider_id': providerId,
      if (imageUrls != null) 'image_urls': imageUrls,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedServicesCompanion copyWith(
      {Value<int>? id,
      Value<String>? slug,
      Value<String>? titleAr,
      Value<String>? titleEn,
      Value<int>? categoryId,
      Value<double>? basePrice,
      Value<String>? currencyCode,
      Value<int>? durationMinutes,
      Value<bool>? isActive,
      Value<double>? ratingAvg,
      Value<int>? reviewsCount,
      Value<int?>? providerId,
      Value<String>? imageUrls,
      Value<String>? rawJson,
      Value<DateTime>? updatedAt}) {
    return CachedServicesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      categoryId: categoryId ?? this.categoryId,
      basePrice: basePrice ?? this.basePrice,
      currencyCode: currencyCode ?? this.currencyCode,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      providerId: providerId ?? this.providerId,
      imageUrls: imageUrls ?? this.imageUrls,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (titleAr.present) {
      map['title_ar'] = Variable<String>(titleAr.value);
    }
    if (titleEn.present) {
      map['title_en'] = Variable<String>(titleEn.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (basePrice.present) {
      map['base_price'] = Variable<double>(basePrice.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (ratingAvg.present) {
      map['rating_avg'] = Variable<double>(ratingAvg.value);
    }
    if (reviewsCount.present) {
      map['reviews_count'] = Variable<int>(reviewsCount.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<int>(providerId.value);
    }
    if (imageUrls.present) {
      map['image_urls'] = Variable<String>(imageUrls.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedServicesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('titleAr: $titleAr, ')
          ..write('titleEn: $titleEn, ')
          ..write('categoryId: $categoryId, ')
          ..write('basePrice: $basePrice, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('ratingAvg: $ratingAvg, ')
          ..write('reviewsCount: $reviewsCount, ')
          ..write('providerId: $providerId, ')
          ..write('imageUrls: $imageUrls, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedProvidersTable extends CachedProviders
    with TableInfo<$CachedProvidersTable, CachedProvider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProvidersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _businessNameMeta =
      const VerificationMeta('businessName');
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
      'business_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingAvgMeta =
      const VerificationMeta('ratingAvg');
  @override
  late final GeneratedColumn<double> ratingAvg = GeneratedColumn<double>(
      'rating_avg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalReviewsMeta =
      const VerificationMeta('totalReviews');
  @override
  late final GeneratedColumn<int> totalReviews = GeneratedColumn<int>(
      'total_reviews', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completedBookingsMeta =
      const VerificationMeta('completedBookings');
  @override
  late final GeneratedColumn<int> completedBookings = GeneratedColumn<int>(
      'completed_bookings', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _coverPhotoMeta =
      const VerificationMeta('coverPhoto');
  @override
  late final GeneratedColumn<String> coverPhoto = GeneratedColumn<String>(
      'cover_photo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serviceAreaCityIdsMeta =
      const VerificationMeta('serviceAreaCityIds');
  @override
  late final GeneratedColumn<String> serviceAreaCityIds =
      GeneratedColumn<String>('service_area_city_ids', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portfolioUrlsMeta =
      const VerificationMeta('portfolioUrls');
  @override
  late final GeneratedColumn<String> portfolioUrls = GeneratedColumn<String>(
      'portfolio_urls', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _walletBalanceMeta =
      const VerificationMeta('walletBalance');
  @override
  late final GeneratedColumn<double> walletBalance = GeneratedColumn<double>(
      'wallet_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalEarningsMeta =
      const VerificationMeta('totalEarnings');
  @override
  late final GeneratedColumn<double> totalEarnings = GeneratedColumn<double>(
      'total_earnings', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        businessName,
        ratingAvg,
        totalReviews,
        completedBookings,
        isVerified,
        coverPhoto,
        serviceAreaCityIds,
        portfolioUrls,
        walletBalance,
        totalEarnings,
        rawJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_providers';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProvider> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('business_name')) {
      context.handle(
          _businessNameMeta,
          businessName.isAcceptableOrUnknown(
              data['business_name']!, _businessNameMeta));
    } else if (isInserting) {
      context.missing(_businessNameMeta);
    }
    if (data.containsKey('rating_avg')) {
      context.handle(_ratingAvgMeta,
          ratingAvg.isAcceptableOrUnknown(data['rating_avg']!, _ratingAvgMeta));
    }
    if (data.containsKey('total_reviews')) {
      context.handle(
          _totalReviewsMeta,
          totalReviews.isAcceptableOrUnknown(
              data['total_reviews']!, _totalReviewsMeta));
    }
    if (data.containsKey('completed_bookings')) {
      context.handle(
          _completedBookingsMeta,
          completedBookings.isAcceptableOrUnknown(
              data['completed_bookings']!, _completedBookingsMeta));
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('cover_photo')) {
      context.handle(
          _coverPhotoMeta,
          coverPhoto.isAcceptableOrUnknown(
              data['cover_photo']!, _coverPhotoMeta));
    }
    if (data.containsKey('service_area_city_ids')) {
      context.handle(
          _serviceAreaCityIdsMeta,
          serviceAreaCityIds.isAcceptableOrUnknown(
              data['service_area_city_ids']!, _serviceAreaCityIdsMeta));
    } else if (isInserting) {
      context.missing(_serviceAreaCityIdsMeta);
    }
    if (data.containsKey('portfolio_urls')) {
      context.handle(
          _portfolioUrlsMeta,
          portfolioUrls.isAcceptableOrUnknown(
              data['portfolio_urls']!, _portfolioUrlsMeta));
    } else if (isInserting) {
      context.missing(_portfolioUrlsMeta);
    }
    if (data.containsKey('wallet_balance')) {
      context.handle(
          _walletBalanceMeta,
          walletBalance.isAcceptableOrUnknown(
              data['wallet_balance']!, _walletBalanceMeta));
    }
    if (data.containsKey('total_earnings')) {
      context.handle(
          _totalEarningsMeta,
          totalEarnings.isAcceptableOrUnknown(
              data['total_earnings']!, _totalEarningsMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CachedProvider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProvider(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      businessName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_name'])!,
      ratingAvg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating_avg'])!,
      totalReviews: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_reviews'])!,
      completedBookings: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}completed_bookings'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      coverPhoto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_photo']),
      serviceAreaCityIds: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}service_area_city_ids'])!,
      portfolioUrls: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}portfolio_urls'])!,
      walletBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}wallet_balance'])!,
      totalEarnings: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_earnings'])!,
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedProvidersTable createAlias(String alias) {
    return $CachedProvidersTable(attachedDatabase, alias);
  }
}

class CachedProvider extends DataClass implements Insertable<CachedProvider> {
  final int userId;
  final String businessName;
  final double ratingAvg;
  final int totalReviews;
  final int completedBookings;
  final bool isVerified;
  final String? coverPhoto;
  final String serviceAreaCityIds;
  final String portfolioUrls;
  final double walletBalance;
  final double totalEarnings;
  final String rawJson;
  final DateTime updatedAt;
  const CachedProvider(
      {required this.userId,
      required this.businessName,
      required this.ratingAvg,
      required this.totalReviews,
      required this.completedBookings,
      required this.isVerified,
      this.coverPhoto,
      required this.serviceAreaCityIds,
      required this.portfolioUrls,
      required this.walletBalance,
      required this.totalEarnings,
      required this.rawJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['business_name'] = Variable<String>(businessName);
    map['rating_avg'] = Variable<double>(ratingAvg);
    map['total_reviews'] = Variable<int>(totalReviews);
    map['completed_bookings'] = Variable<int>(completedBookings);
    map['is_verified'] = Variable<bool>(isVerified);
    if (!nullToAbsent || coverPhoto != null) {
      map['cover_photo'] = Variable<String>(coverPhoto);
    }
    map['service_area_city_ids'] = Variable<String>(serviceAreaCityIds);
    map['portfolio_urls'] = Variable<String>(portfolioUrls);
    map['wallet_balance'] = Variable<double>(walletBalance);
    map['total_earnings'] = Variable<double>(totalEarnings);
    map['raw_json'] = Variable<String>(rawJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedProvidersCompanion toCompanion(bool nullToAbsent) {
    return CachedProvidersCompanion(
      userId: Value(userId),
      businessName: Value(businessName),
      ratingAvg: Value(ratingAvg),
      totalReviews: Value(totalReviews),
      completedBookings: Value(completedBookings),
      isVerified: Value(isVerified),
      coverPhoto: coverPhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhoto),
      serviceAreaCityIds: Value(serviceAreaCityIds),
      portfolioUrls: Value(portfolioUrls),
      walletBalance: Value(walletBalance),
      totalEarnings: Value(totalEarnings),
      rawJson: Value(rawJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedProvider.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProvider(
      userId: serializer.fromJson<int>(json['userId']),
      businessName: serializer.fromJson<String>(json['businessName']),
      ratingAvg: serializer.fromJson<double>(json['ratingAvg']),
      totalReviews: serializer.fromJson<int>(json['totalReviews']),
      completedBookings: serializer.fromJson<int>(json['completedBookings']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      coverPhoto: serializer.fromJson<String?>(json['coverPhoto']),
      serviceAreaCityIds:
          serializer.fromJson<String>(json['serviceAreaCityIds']),
      portfolioUrls: serializer.fromJson<String>(json['portfolioUrls']),
      walletBalance: serializer.fromJson<double>(json['walletBalance']),
      totalEarnings: serializer.fromJson<double>(json['totalEarnings']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'businessName': serializer.toJson<String>(businessName),
      'ratingAvg': serializer.toJson<double>(ratingAvg),
      'totalReviews': serializer.toJson<int>(totalReviews),
      'completedBookings': serializer.toJson<int>(completedBookings),
      'isVerified': serializer.toJson<bool>(isVerified),
      'coverPhoto': serializer.toJson<String?>(coverPhoto),
      'serviceAreaCityIds': serializer.toJson<String>(serviceAreaCityIds),
      'portfolioUrls': serializer.toJson<String>(portfolioUrls),
      'walletBalance': serializer.toJson<double>(walletBalance),
      'totalEarnings': serializer.toJson<double>(totalEarnings),
      'rawJson': serializer.toJson<String>(rawJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedProvider copyWith(
          {int? userId,
          String? businessName,
          double? ratingAvg,
          int? totalReviews,
          int? completedBookings,
          bool? isVerified,
          Value<String?> coverPhoto = const Value.absent(),
          String? serviceAreaCityIds,
          String? portfolioUrls,
          double? walletBalance,
          double? totalEarnings,
          String? rawJson,
          DateTime? updatedAt}) =>
      CachedProvider(
        userId: userId ?? this.userId,
        businessName: businessName ?? this.businessName,
        ratingAvg: ratingAvg ?? this.ratingAvg,
        totalReviews: totalReviews ?? this.totalReviews,
        completedBookings: completedBookings ?? this.completedBookings,
        isVerified: isVerified ?? this.isVerified,
        coverPhoto: coverPhoto.present ? coverPhoto.value : this.coverPhoto,
        serviceAreaCityIds: serviceAreaCityIds ?? this.serviceAreaCityIds,
        portfolioUrls: portfolioUrls ?? this.portfolioUrls,
        walletBalance: walletBalance ?? this.walletBalance,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        rawJson: rawJson ?? this.rawJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedProvider copyWithCompanion(CachedProvidersCompanion data) {
    return CachedProvider(
      userId: data.userId.present ? data.userId.value : this.userId,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      ratingAvg: data.ratingAvg.present ? data.ratingAvg.value : this.ratingAvg,
      totalReviews: data.totalReviews.present
          ? data.totalReviews.value
          : this.totalReviews,
      completedBookings: data.completedBookings.present
          ? data.completedBookings.value
          : this.completedBookings,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      coverPhoto:
          data.coverPhoto.present ? data.coverPhoto.value : this.coverPhoto,
      serviceAreaCityIds: data.serviceAreaCityIds.present
          ? data.serviceAreaCityIds.value
          : this.serviceAreaCityIds,
      portfolioUrls: data.portfolioUrls.present
          ? data.portfolioUrls.value
          : this.portfolioUrls,
      walletBalance: data.walletBalance.present
          ? data.walletBalance.value
          : this.walletBalance,
      totalEarnings: data.totalEarnings.present
          ? data.totalEarnings.value
          : this.totalEarnings,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProvider(')
          ..write('userId: $userId, ')
          ..write('businessName: $businessName, ')
          ..write('ratingAvg: $ratingAvg, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('completedBookings: $completedBookings, ')
          ..write('isVerified: $isVerified, ')
          ..write('coverPhoto: $coverPhoto, ')
          ..write('serviceAreaCityIds: $serviceAreaCityIds, ')
          ..write('portfolioUrls: $portfolioUrls, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('totalEarnings: $totalEarnings, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      businessName,
      ratingAvg,
      totalReviews,
      completedBookings,
      isVerified,
      coverPhoto,
      serviceAreaCityIds,
      portfolioUrls,
      walletBalance,
      totalEarnings,
      rawJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProvider &&
          other.userId == this.userId &&
          other.businessName == this.businessName &&
          other.ratingAvg == this.ratingAvg &&
          other.totalReviews == this.totalReviews &&
          other.completedBookings == this.completedBookings &&
          other.isVerified == this.isVerified &&
          other.coverPhoto == this.coverPhoto &&
          other.serviceAreaCityIds == this.serviceAreaCityIds &&
          other.portfolioUrls == this.portfolioUrls &&
          other.walletBalance == this.walletBalance &&
          other.totalEarnings == this.totalEarnings &&
          other.rawJson == this.rawJson &&
          other.updatedAt == this.updatedAt);
}

class CachedProvidersCompanion extends UpdateCompanion<CachedProvider> {
  final Value<int> userId;
  final Value<String> businessName;
  final Value<double> ratingAvg;
  final Value<int> totalReviews;
  final Value<int> completedBookings;
  final Value<bool> isVerified;
  final Value<String?> coverPhoto;
  final Value<String> serviceAreaCityIds;
  final Value<String> portfolioUrls;
  final Value<double> walletBalance;
  final Value<double> totalEarnings;
  final Value<String> rawJson;
  final Value<DateTime> updatedAt;
  const CachedProvidersCompanion({
    this.userId = const Value.absent(),
    this.businessName = const Value.absent(),
    this.ratingAvg = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.completedBookings = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.coverPhoto = const Value.absent(),
    this.serviceAreaCityIds = const Value.absent(),
    this.portfolioUrls = const Value.absent(),
    this.walletBalance = const Value.absent(),
    this.totalEarnings = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CachedProvidersCompanion.insert({
    this.userId = const Value.absent(),
    required String businessName,
    this.ratingAvg = const Value.absent(),
    this.totalReviews = const Value.absent(),
    this.completedBookings = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.coverPhoto = const Value.absent(),
    required String serviceAreaCityIds,
    required String portfolioUrls,
    this.walletBalance = const Value.absent(),
    this.totalEarnings = const Value.absent(),
    required String rawJson,
    required DateTime updatedAt,
  })  : businessName = Value(businessName),
        serviceAreaCityIds = Value(serviceAreaCityIds),
        portfolioUrls = Value(portfolioUrls),
        rawJson = Value(rawJson),
        updatedAt = Value(updatedAt);
  static Insertable<CachedProvider> custom({
    Expression<int>? userId,
    Expression<String>? businessName,
    Expression<double>? ratingAvg,
    Expression<int>? totalReviews,
    Expression<int>? completedBookings,
    Expression<bool>? isVerified,
    Expression<String>? coverPhoto,
    Expression<String>? serviceAreaCityIds,
    Expression<String>? portfolioUrls,
    Expression<double>? walletBalance,
    Expression<double>? totalEarnings,
    Expression<String>? rawJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (businessName != null) 'business_name': businessName,
      if (ratingAvg != null) 'rating_avg': ratingAvg,
      if (totalReviews != null) 'total_reviews': totalReviews,
      if (completedBookings != null) 'completed_bookings': completedBookings,
      if (isVerified != null) 'is_verified': isVerified,
      if (coverPhoto != null) 'cover_photo': coverPhoto,
      if (serviceAreaCityIds != null)
        'service_area_city_ids': serviceAreaCityIds,
      if (portfolioUrls != null) 'portfolio_urls': portfolioUrls,
      if (walletBalance != null) 'wallet_balance': walletBalance,
      if (totalEarnings != null) 'total_earnings': totalEarnings,
      if (rawJson != null) 'raw_json': rawJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CachedProvidersCompanion copyWith(
      {Value<int>? userId,
      Value<String>? businessName,
      Value<double>? ratingAvg,
      Value<int>? totalReviews,
      Value<int>? completedBookings,
      Value<bool>? isVerified,
      Value<String?>? coverPhoto,
      Value<String>? serviceAreaCityIds,
      Value<String>? portfolioUrls,
      Value<double>? walletBalance,
      Value<double>? totalEarnings,
      Value<String>? rawJson,
      Value<DateTime>? updatedAt}) {
    return CachedProvidersCompanion(
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalReviews: totalReviews ?? this.totalReviews,
      completedBookings: completedBookings ?? this.completedBookings,
      isVerified: isVerified ?? this.isVerified,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      serviceAreaCityIds: serviceAreaCityIds ?? this.serviceAreaCityIds,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rawJson: rawJson ?? this.rawJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (ratingAvg.present) {
      map['rating_avg'] = Variable<double>(ratingAvg.value);
    }
    if (totalReviews.present) {
      map['total_reviews'] = Variable<int>(totalReviews.value);
    }
    if (completedBookings.present) {
      map['completed_bookings'] = Variable<int>(completedBookings.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (coverPhoto.present) {
      map['cover_photo'] = Variable<String>(coverPhoto.value);
    }
    if (serviceAreaCityIds.present) {
      map['service_area_city_ids'] = Variable<String>(serviceAreaCityIds.value);
    }
    if (portfolioUrls.present) {
      map['portfolio_urls'] = Variable<String>(portfolioUrls.value);
    }
    if (walletBalance.present) {
      map['wallet_balance'] = Variable<double>(walletBalance.value);
    }
    if (totalEarnings.present) {
      map['total_earnings'] = Variable<double>(totalEarnings.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProvidersCompanion(')
          ..write('userId: $userId, ')
          ..write('businessName: $businessName, ')
          ..write('ratingAvg: $ratingAvg, ')
          ..write('totalReviews: $totalReviews, ')
          ..write('completedBookings: $completedBookings, ')
          ..write('isVerified: $isVerified, ')
          ..write('coverPhoto: $coverPhoto, ')
          ..write('serviceAreaCityIds: $serviceAreaCityIds, ')
          ..write('portfolioUrls: $portfolioUrls, ')
          ..write('walletBalance: $walletBalance, ')
          ..write('totalEarnings: $totalEarnings, ')
          ..write('rawJson: $rawJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusIndexMeta =
      const VerificationMeta('statusIndex');
  @override
  late final GeneratedColumn<int> statusIndex = GeneratedColumn<int>(
      'status_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, operation, payload, retryCount, createdAt, statusIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status_index')) {
      context.handle(
          _statusIndexMeta,
          statusIndex.isAcceptableOrUnknown(
              data['status_index']!, _statusIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      statusIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status_index'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String operation;
  final String payload;
  final int retryCount;
  final DateTime createdAt;
  final int statusIndex;
  const SyncQueueData(
      {required this.id,
      required this.operation,
      required this.payload,
      required this.retryCount,
      required this.createdAt,
      required this.statusIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status_index'] = Variable<int>(statusIndex);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      payload: Value(payload),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      statusIndex: Value(statusIndex),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      statusIndex: serializer.fromJson<int>(json['statusIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'statusIndex': serializer.toJson<int>(statusIndex),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? operation,
          String? payload,
          int? retryCount,
          DateTime? createdAt,
          int? statusIndex}) =>
      SyncQueueData(
        id: id ?? this.id,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
        statusIndex: statusIndex ?? this.statusIndex,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      statusIndex:
          data.statusIndex.present ? data.statusIndex.value : this.statusIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('statusIndex: $statusIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operation, payload, retryCount, createdAt, statusIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.statusIndex == this.statusIndex);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<int> statusIndex;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.statusIndex = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String payload,
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
    this.statusIndex = const Value.absent(),
  })  : operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<int>? statusIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (statusIndex != null) 'status_index': statusIndex,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? operation,
      Value<String>? payload,
      Value<int>? retryCount,
      Value<DateTime>? createdAt,
      Value<int>? statusIndex}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      statusIndex: statusIndex ?? this.statusIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (statusIndex.present) {
      map['status_index'] = Variable<int>(statusIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('statusIndex: $statusIndex')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineDb extends GeneratedDatabase {
  _$OfflineDb(QueryExecutor e) : super(e);
  $OfflineDbManager get managers => $OfflineDbManager(this);
  late final $CachedBookingsTable cachedBookings = $CachedBookingsTable(this);
  late final $CachedServicesTable cachedServices = $CachedServicesTable(this);
  late final $CachedProvidersTable cachedProviders =
      $CachedProvidersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cachedBookings, cachedServices, cachedProviders, syncQueue];
}

typedef $$CachedBookingsTableCreateCompanionBuilder = CachedBookingsCompanion
    Function({
  Value<int> id,
  required String bookingNumber,
  required int statusIndex,
  required int customerId,
  Value<int?> providerId,
  required int serviceId,
  required double total,
  required String currencyCode,
  Value<DateTime?> scheduledAt,
  required String rawJson,
  required DateTime updatedAt,
});
typedef $$CachedBookingsTableUpdateCompanionBuilder = CachedBookingsCompanion
    Function({
  Value<int> id,
  Value<String> bookingNumber,
  Value<int> statusIndex,
  Value<int> customerId,
  Value<int?> providerId,
  Value<int> serviceId,
  Value<double> total,
  Value<String> currencyCode,
  Value<DateTime?> scheduledAt,
  Value<String> rawJson,
  Value<DateTime> updatedAt,
});

class $$CachedBookingsTableTableManager extends RootTableManager<
    _$OfflineDb,
    $CachedBookingsTable,
    CachedBooking,
    $$CachedBookingsTableFilterComposer,
    $$CachedBookingsTableOrderingComposer,
    $$CachedBookingsTableCreateCompanionBuilder,
    $$CachedBookingsTableUpdateCompanionBuilder> {
  $$CachedBookingsTableTableManager(_$OfflineDb db, $CachedBookingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CachedBookingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CachedBookingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> bookingNumber = const Value.absent(),
            Value<int> statusIndex = const Value.absent(),
            Value<int> customerId = const Value.absent(),
            Value<int?> providerId = const Value.absent(),
            Value<int> serviceId = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedBookingsCompanion(
            id: id,
            bookingNumber: bookingNumber,
            statusIndex: statusIndex,
            customerId: customerId,
            providerId: providerId,
            serviceId: serviceId,
            total: total,
            currencyCode: currencyCode,
            scheduledAt: scheduledAt,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String bookingNumber,
            required int statusIndex,
            required int customerId,
            Value<int?> providerId = const Value.absent(),
            required int serviceId,
            required double total,
            required String currencyCode,
            Value<DateTime?> scheduledAt = const Value.absent(),
            required String rawJson,
            required DateTime updatedAt,
          }) =>
              CachedBookingsCompanion.insert(
            id: id,
            bookingNumber: bookingNumber,
            statusIndex: statusIndex,
            customerId: customerId,
            providerId: providerId,
            serviceId: serviceId,
            total: total,
            currencyCode: currencyCode,
            scheduledAt: scheduledAt,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
        ));
}

class $$CachedBookingsTableFilterComposer
    extends FilterComposer<_$OfflineDb, $CachedBookingsTable> {
  $$CachedBookingsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get bookingNumber => $state.composableBuilder(
      column: $state.table.bookingNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get statusIndex => $state.composableBuilder(
      column: $state.table.statusIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get customerId => $state.composableBuilder(
      column: $state.table.customerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get providerId => $state.composableBuilder(
      column: $state.table.providerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get serviceId => $state.composableBuilder(
      column: $state.table.serviceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get total => $state.composableBuilder(
      column: $state.table.total,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currencyCode => $state.composableBuilder(
      column: $state.table.currencyCode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get scheduledAt => $state.composableBuilder(
      column: $state.table.scheduledAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CachedBookingsTableOrderingComposer
    extends OrderingComposer<_$OfflineDb, $CachedBookingsTable> {
  $$CachedBookingsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get bookingNumber => $state.composableBuilder(
      column: $state.table.bookingNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get statusIndex => $state.composableBuilder(
      column: $state.table.statusIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get customerId => $state.composableBuilder(
      column: $state.table.customerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get providerId => $state.composableBuilder(
      column: $state.table.providerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get serviceId => $state.composableBuilder(
      column: $state.table.serviceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get total => $state.composableBuilder(
      column: $state.table.total,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currencyCode => $state.composableBuilder(
      column: $state.table.currencyCode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get scheduledAt => $state.composableBuilder(
      column: $state.table.scheduledAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CachedServicesTableCreateCompanionBuilder = CachedServicesCompanion
    Function({
  Value<int> id,
  required String slug,
  required String titleAr,
  required String titleEn,
  required int categoryId,
  required double basePrice,
  required String currencyCode,
  required int durationMinutes,
  required bool isActive,
  Value<double> ratingAvg,
  Value<int> reviewsCount,
  Value<int?> providerId,
  required String imageUrls,
  required String rawJson,
  required DateTime updatedAt,
});
typedef $$CachedServicesTableUpdateCompanionBuilder = CachedServicesCompanion
    Function({
  Value<int> id,
  Value<String> slug,
  Value<String> titleAr,
  Value<String> titleEn,
  Value<int> categoryId,
  Value<double> basePrice,
  Value<String> currencyCode,
  Value<int> durationMinutes,
  Value<bool> isActive,
  Value<double> ratingAvg,
  Value<int> reviewsCount,
  Value<int?> providerId,
  Value<String> imageUrls,
  Value<String> rawJson,
  Value<DateTime> updatedAt,
});

class $$CachedServicesTableTableManager extends RootTableManager<
    _$OfflineDb,
    $CachedServicesTable,
    CachedService,
    $$CachedServicesTableFilterComposer,
    $$CachedServicesTableOrderingComposer,
    $$CachedServicesTableCreateCompanionBuilder,
    $$CachedServicesTableUpdateCompanionBuilder> {
  $$CachedServicesTableTableManager(_$OfflineDb db, $CachedServicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CachedServicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CachedServicesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> slug = const Value.absent(),
            Value<String> titleAr = const Value.absent(),
            Value<String> titleEn = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> basePrice = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<double> ratingAvg = const Value.absent(),
            Value<int> reviewsCount = const Value.absent(),
            Value<int?> providerId = const Value.absent(),
            Value<String> imageUrls = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedServicesCompanion(
            id: id,
            slug: slug,
            titleAr: titleAr,
            titleEn: titleEn,
            categoryId: categoryId,
            basePrice: basePrice,
            currencyCode: currencyCode,
            durationMinutes: durationMinutes,
            isActive: isActive,
            ratingAvg: ratingAvg,
            reviewsCount: reviewsCount,
            providerId: providerId,
            imageUrls: imageUrls,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String slug,
            required String titleAr,
            required String titleEn,
            required int categoryId,
            required double basePrice,
            required String currencyCode,
            required int durationMinutes,
            required bool isActive,
            Value<double> ratingAvg = const Value.absent(),
            Value<int> reviewsCount = const Value.absent(),
            Value<int?> providerId = const Value.absent(),
            required String imageUrls,
            required String rawJson,
            required DateTime updatedAt,
          }) =>
              CachedServicesCompanion.insert(
            id: id,
            slug: slug,
            titleAr: titleAr,
            titleEn: titleEn,
            categoryId: categoryId,
            basePrice: basePrice,
            currencyCode: currencyCode,
            durationMinutes: durationMinutes,
            isActive: isActive,
            ratingAvg: ratingAvg,
            reviewsCount: reviewsCount,
            providerId: providerId,
            imageUrls: imageUrls,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
        ));
}

class $$CachedServicesTableFilterComposer
    extends FilterComposer<_$OfflineDb, $CachedServicesTable> {
  $$CachedServicesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get slug => $state.composableBuilder(
      column: $state.table.slug,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get titleAr => $state.composableBuilder(
      column: $state.table.titleAr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get titleEn => $state.composableBuilder(
      column: $state.table.titleEn,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get basePrice => $state.composableBuilder(
      column: $state.table.basePrice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get currencyCode => $state.composableBuilder(
      column: $state.table.currencyCode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get durationMinutes => $state.composableBuilder(
      column: $state.table.durationMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get ratingAvg => $state.composableBuilder(
      column: $state.table.ratingAvg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get reviewsCount => $state.composableBuilder(
      column: $state.table.reviewsCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get providerId => $state.composableBuilder(
      column: $state.table.providerId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get imageUrls => $state.composableBuilder(
      column: $state.table.imageUrls,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CachedServicesTableOrderingComposer
    extends OrderingComposer<_$OfflineDb, $CachedServicesTable> {
  $$CachedServicesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get slug => $state.composableBuilder(
      column: $state.table.slug,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get titleAr => $state.composableBuilder(
      column: $state.table.titleAr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get titleEn => $state.composableBuilder(
      column: $state.table.titleEn,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get categoryId => $state.composableBuilder(
      column: $state.table.categoryId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get basePrice => $state.composableBuilder(
      column: $state.table.basePrice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get currencyCode => $state.composableBuilder(
      column: $state.table.currencyCode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get durationMinutes => $state.composableBuilder(
      column: $state.table.durationMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get ratingAvg => $state.composableBuilder(
      column: $state.table.ratingAvg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get reviewsCount => $state.composableBuilder(
      column: $state.table.reviewsCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get providerId => $state.composableBuilder(
      column: $state.table.providerId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get imageUrls => $state.composableBuilder(
      column: $state.table.imageUrls,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CachedProvidersTableCreateCompanionBuilder = CachedProvidersCompanion
    Function({
  Value<int> userId,
  required String businessName,
  Value<double> ratingAvg,
  Value<int> totalReviews,
  Value<int> completedBookings,
  Value<bool> isVerified,
  Value<String?> coverPhoto,
  required String serviceAreaCityIds,
  required String portfolioUrls,
  Value<double> walletBalance,
  Value<double> totalEarnings,
  required String rawJson,
  required DateTime updatedAt,
});
typedef $$CachedProvidersTableUpdateCompanionBuilder = CachedProvidersCompanion
    Function({
  Value<int> userId,
  Value<String> businessName,
  Value<double> ratingAvg,
  Value<int> totalReviews,
  Value<int> completedBookings,
  Value<bool> isVerified,
  Value<String?> coverPhoto,
  Value<String> serviceAreaCityIds,
  Value<String> portfolioUrls,
  Value<double> walletBalance,
  Value<double> totalEarnings,
  Value<String> rawJson,
  Value<DateTime> updatedAt,
});

class $$CachedProvidersTableTableManager extends RootTableManager<
    _$OfflineDb,
    $CachedProvidersTable,
    CachedProvider,
    $$CachedProvidersTableFilterComposer,
    $$CachedProvidersTableOrderingComposer,
    $$CachedProvidersTableCreateCompanionBuilder,
    $$CachedProvidersTableUpdateCompanionBuilder> {
  $$CachedProvidersTableTableManager(
      _$OfflineDb db, $CachedProvidersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CachedProvidersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CachedProvidersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            Value<String> businessName = const Value.absent(),
            Value<double> ratingAvg = const Value.absent(),
            Value<int> totalReviews = const Value.absent(),
            Value<int> completedBookings = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<String?> coverPhoto = const Value.absent(),
            Value<String> serviceAreaCityIds = const Value.absent(),
            Value<String> portfolioUrls = const Value.absent(),
            Value<double> walletBalance = const Value.absent(),
            Value<double> totalEarnings = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CachedProvidersCompanion(
            userId: userId,
            businessName: businessName,
            ratingAvg: ratingAvg,
            totalReviews: totalReviews,
            completedBookings: completedBookings,
            isVerified: isVerified,
            coverPhoto: coverPhoto,
            serviceAreaCityIds: serviceAreaCityIds,
            portfolioUrls: portfolioUrls,
            walletBalance: walletBalance,
            totalEarnings: totalEarnings,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> userId = const Value.absent(),
            required String businessName,
            Value<double> ratingAvg = const Value.absent(),
            Value<int> totalReviews = const Value.absent(),
            Value<int> completedBookings = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<String?> coverPhoto = const Value.absent(),
            required String serviceAreaCityIds,
            required String portfolioUrls,
            Value<double> walletBalance = const Value.absent(),
            Value<double> totalEarnings = const Value.absent(),
            required String rawJson,
            required DateTime updatedAt,
          }) =>
              CachedProvidersCompanion.insert(
            userId: userId,
            businessName: businessName,
            ratingAvg: ratingAvg,
            totalReviews: totalReviews,
            completedBookings: completedBookings,
            isVerified: isVerified,
            coverPhoto: coverPhoto,
            serviceAreaCityIds: serviceAreaCityIds,
            portfolioUrls: portfolioUrls,
            walletBalance: walletBalance,
            totalEarnings: totalEarnings,
            rawJson: rawJson,
            updatedAt: updatedAt,
          ),
        ));
}

class $$CachedProvidersTableFilterComposer
    extends FilterComposer<_$OfflineDb, $CachedProvidersTable> {
  $$CachedProvidersTableFilterComposer(super.$state);
  ColumnFilters<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get businessName => $state.composableBuilder(
      column: $state.table.businessName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get ratingAvg => $state.composableBuilder(
      column: $state.table.ratingAvg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalReviews => $state.composableBuilder(
      column: $state.table.totalReviews,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get completedBookings => $state.composableBuilder(
      column: $state.table.completedBookings,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isVerified => $state.composableBuilder(
      column: $state.table.isVerified,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get coverPhoto => $state.composableBuilder(
      column: $state.table.coverPhoto,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get serviceAreaCityIds => $state.composableBuilder(
      column: $state.table.serviceAreaCityIds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get portfolioUrls => $state.composableBuilder(
      column: $state.table.portfolioUrls,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get walletBalance => $state.composableBuilder(
      column: $state.table.walletBalance,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalEarnings => $state.composableBuilder(
      column: $state.table.totalEarnings,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CachedProvidersTableOrderingComposer
    extends OrderingComposer<_$OfflineDb, $CachedProvidersTable> {
  $$CachedProvidersTableOrderingComposer(super.$state);
  ColumnOrderings<int> get userId => $state.composableBuilder(
      column: $state.table.userId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get businessName => $state.composableBuilder(
      column: $state.table.businessName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get ratingAvg => $state.composableBuilder(
      column: $state.table.ratingAvg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalReviews => $state.composableBuilder(
      column: $state.table.totalReviews,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get completedBookings => $state.composableBuilder(
      column: $state.table.completedBookings,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isVerified => $state.composableBuilder(
      column: $state.table.isVerified,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get coverPhoto => $state.composableBuilder(
      column: $state.table.coverPhoto,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get serviceAreaCityIds => $state.composableBuilder(
      column: $state.table.serviceAreaCityIds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get portfolioUrls => $state.composableBuilder(
      column: $state.table.portfolioUrls,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get walletBalance => $state.composableBuilder(
      column: $state.table.walletBalance,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalEarnings => $state.composableBuilder(
      column: $state.table.totalEarnings,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get rawJson => $state.composableBuilder(
      column: $state.table.rawJson,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String operation,
  required String payload,
  Value<int> retryCount,
  required DateTime createdAt,
  Value<int> statusIndex,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> operation,
  Value<String> payload,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<int> statusIndex,
});

class $$SyncQueueTableTableManager extends RootTableManager<
    _$OfflineDb,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder> {
  $$SyncQueueTableTableManager(_$OfflineDb db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SyncQueueTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SyncQueueTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> statusIndex = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            operation: operation,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            statusIndex: statusIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String operation,
            required String payload,
            Value<int> retryCount = const Value.absent(),
            required DateTime createdAt,
            Value<int> statusIndex = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            operation: operation,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            statusIndex: statusIndex,
          ),
        ));
}

class $$SyncQueueTableFilterComposer
    extends FilterComposer<_$OfflineDb, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get statusIndex => $state.composableBuilder(
      column: $state.table.statusIndex,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SyncQueueTableOrderingComposer
    extends OrderingComposer<_$OfflineDb, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get operation => $state.composableBuilder(
      column: $state.table.operation,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get payload => $state.composableBuilder(
      column: $state.table.payload,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get retryCount => $state.composableBuilder(
      column: $state.table.retryCount,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get statusIndex => $state.composableBuilder(
      column: $state.table.statusIndex,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $OfflineDbManager {
  final _$OfflineDb _db;
  $OfflineDbManager(this._db);
  $$CachedBookingsTableTableManager get cachedBookings =>
      $$CachedBookingsTableTableManager(_db, _db.cachedBookings);
  $$CachedServicesTableTableManager get cachedServices =>
      $$CachedServicesTableTableManager(_db, _db.cachedServices);
  $$CachedProvidersTableTableManager get cachedProviders =>
      $$CachedProvidersTableTableManager(_db, _db.cachedProviders);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
