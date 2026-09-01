import 'package:chat_bot/utils/utility.dart';

/// Response model for GET /v1/wallet (walletData & walletEarningData).
class WalletData {
  const WalletData({
    this.userid,
    this.usertype,
    this.currency,
    this.createddate,
    this.balance,
    this.hardLimit,
    this.isHardLimitHit,
    this.isSoftLimitHit,
    this.pendingamount,
    this.softLimit,
    this.status,
    this.statustext,
    this.walletid,
    this.withdrawalLimit,
    this.currencySymbol,
  });

  final String? userid;
  final String? usertype;
  final String? currency;
  final String? createddate;
  final String? balance;
  final int? hardLimit;
  final bool? isHardLimitHit;
  final bool? isSoftLimitHit;
  final String? pendingamount;
  final int? softLimit;
  final int? status;
  final String? statustext;
  final String? walletid;
  final int? withdrawalLimit;
  final String? currencySymbol;

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      userid: json['userid'] as String?,
      usertype: json['usertype'] as String?,
      currency: json['currency'] as String?,
      createddate: json['createddate'] as String?,
      balance: json['balance']?.toString(),
      hardLimit: json['hard_limit'] as int?,
      isHardLimitHit: json['is_hard_limit_hit'] as bool?,
      isSoftLimitHit: json['is_soft_limit_hit'] as bool?,
      pendingamount: json['pendingamount']?.toString(),
      softLimit: json['soft_limit'] as int?,
      status: json['status'] as int?,
      statustext: json['statustext'] as String?,
      walletid: json['walletid'] as String?,
      withdrawalLimit: json['withdrawal_limit'] as int?,
      currencySymbol: json['currency_symbol'] as String?,
    );
  }
}

class WalletEarningData {
  const WalletEarningData({
    this.balance,
    this.createddate,
    this.status,
    this.statustext,
    this.userid,
    this.usertype,
    this.walletearningid,
  });

  final String? balance;
  final String? createddate;
  final int? status;
  final String? statustext;
  final String? userid;
  final String? usertype;
  final String? walletearningid;

  factory WalletEarningData.fromJson(Map<String, dynamic> json) {
    return WalletEarningData(
      balance: json['balance']?.toString(),
      createddate: json['createddate'] as String?,
      status: json['status'] as int?,
      statustext: json['statustext'] as String?,
      userid: json['userid'] as String?,
      usertype: json['usertype'] as String?,
      walletearningid: json['walletearningid'] as String?,
    );
  }
}

class WalletResponse {
  const WalletResponse({
    this.walletData,
    this.walletEarningData,
  });

  final List<WalletData>? walletData;
  final List<WalletEarningData>? walletEarningData;

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) return const WalletResponse();

    final walletList = data['walletData'];
    final earningList = data['walletEarningData'];

    return WalletResponse(
      walletData: walletList is List
          ? (walletList)
              .map((e) => WalletData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
      walletEarningData: earningList is List
          ? (earningList)
              .map((e) =>
                  WalletEarningData.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
    );
  }

  /// First wallet balance with symbol (e.g. "₹12696.96").
  String get displayBalance {
    final wallet = walletData?.isNotEmpty == true ? walletData!.first : null;
    if (wallet == null) return '—';
    final sym = wallet.currency ?? '';
    final bal = wallet.balance ?? '0';
    final formatted = Utility.formatNumberWithCommas(bal, fixedDecimalPlaces: 2);
    return '$sym $formatted';
  }

  /// First earning balance for Xtra (e.g. "2,186.22").
  String get displayEarningBalance {
    final earning =
        walletEarningData?.isNotEmpty == true ? walletEarningData!.first : null;
    if (earning == null) return '0';
    return Utility.formatNumberWithCommas(earning.balance ?? '0');
  }
}
