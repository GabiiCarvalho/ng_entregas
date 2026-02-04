class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isDriver;
  final WalletInfo wallet;
  final UserRatings ratings;
  final List<String> paymentMethods;
  final List<Map<String, dynamic>> recentAddresses;
  final String userType; // 'client' ou 'driver'
  final String blockStatus; // 'no' ou 'yes'
  final bool emailVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
    required this.isDriver,
    required this.wallet,
    required this.ratings,
    required this.paymentMethods,
    required this.recentAddresses,
    this.userType = 'client',
    this.blockStatus = 'no',
    this.emailVerified = false,
  });

  // Método para criar cópia com alterações
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
    bool? isDriver,
    WalletInfo? wallet,
    UserRatings? ratings,
    List<String>? paymentMethods,
    List<Map<String, dynamic>>? recentAddresses,
    String? userType,
    String? blockStatus,
    bool? emailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isDriver: isDriver ?? this.isDriver,
      wallet: wallet ?? this.wallet,
      ratings: ratings ?? this.ratings,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      recentAddresses: recentAddresses ?? this.recentAddresses,
      userType: userType ?? this.userType,
      blockStatus: blockStatus ?? this.blockStatus,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  // Converter para Map (para Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isDriver': isDriver,
      'wallet': wallet.toMap(),
      'ratings': ratings.toMap(),
      'paymentMethods': paymentMethods,
      'recentAddresses': recentAddresses,
      'userType': userType,
      'blockStatus': blockStatus,
      'emailVerified': emailVerified,
    };
  }

  // Criar a partir de Map (do Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      isDriver: map['isDriver'] ?? false,
      wallet: map['wallet'] != null
          ? WalletInfo.fromMap(Map<String, dynamic>.from(map['wallet']))
          : WalletInfo(balance: 0.0, transactions: []),
      ratings: map['ratings'] != null
          ? UserRatings.fromMap(Map<String, dynamic>.from(map['ratings']))
          : UserRatings(average: 5.0, count: 0),
      paymentMethods: map['paymentMethods'] != null
          ? List<String>.from(map['paymentMethods'])
          : [],
      recentAddresses: map['recentAddresses'] != null
          ? List<Map<String, dynamic>>.from(map['recentAddresses'])
          : [],
      userType: map['userType'] ?? 'client',
      blockStatus: map['blockStatus'] ?? 'no',
      emailVerified: map['emailVerified'] ?? false,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, userType: $userType)';
  }
}

class WalletInfo {
  final double balance;
  final List<Map<String, dynamic>> transactions;

  WalletInfo({required this.balance, required this.transactions});

  Map<String, dynamic> toMap() {
    return {'balance': balance, 'transactions': transactions};
  }

  factory WalletInfo.fromMap(Map<String, dynamic> map) {
    return WalletInfo(
      balance: map['balance']?.toDouble() ?? 0.0,
      transactions: map['transactions'] != null
          ? List<Map<String, dynamic>>.from(map['transactions'])
          : [],
    );
  }

  WalletInfo copyWith({
    double? balance,
    List<Map<String, dynamic>>? transactions,
  }) {
    return WalletInfo(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class UserRatings {
  final double average;
  final int count;

  UserRatings({required this.average, required this.count});

  Map<String, dynamic> toMap() {
    return {'average': average, 'count': count};
  }

  factory UserRatings.fromMap(Map<String, dynamic> map) {
    return UserRatings(
      average: map['average']?.toDouble() ?? 0.0,
      count: map['count']?.toInt() ?? 0,
    );
  }

  UserRatings copyWith({double? average, int? count}) {
    return UserRatings(
      average: average ?? this.average,
      count: count ?? this.count,
    );
  }
}
