enum BillingProductId {
  singleSheet('aura_sheet_9', slots: 9, isSubscription: false),
  packFiveSheets('aura_sheet_pack_5', slots: 45, isSubscription: false),
  packTenSheets('aura_sheet_pack_10', slots: 90, isSubscription: false),
  compactBinder('aura_binder_160', slots: 160, isSubscription: false),
  standardBinder('aura_binder_360', slots: 360, isSubscription: false),
  packThreeBinders('aura_binder_pack_3', slots: 360, isSubscription: false),
  auraProMonthly('aura_pro_monthly', slots: 900, isSubscription: true),
  auraProAnnual('aura_pro_annual', slots: 900, isSubscription: true);

  const BillingProductId(
    this.productId, {
    required this.slots,
    required this.isSubscription,
  });

  final String productId;
  final int slots;
  final bool isSubscription;
}

class BillingPurchaseResult {
  const BillingPurchaseResult({
    required this.success,
    required this.productId,
    this.transactionId,
    this.errorMessage,
  });

  final bool success;
  final String productId;
  final String? transactionId;
  final String? errorMessage;
}

class BillingEntitlements {
  const BillingEntitlements({
    required this.isPro,
    required this.extraBinderCredits,
    this.availableSlots = 0,
  });

  final bool isPro;
  final int extraBinderCredits;
  final int availableSlots;
}

/// Puente desacoplado de monetización preparado para conectar RevenueCat.
abstract interface class BillingService {
  Future<void> initialize({required String appUserId});

  Future<BillingEntitlements> getEntitlements();

  Future<BillingPurchaseResult> purchaseProduct(BillingProductId product);

  Future<BillingEntitlements> restorePurchases();
}

class MockBillingService implements BillingService {
  bool _isPro = false;
  int _extraCredits = 0;
  int _availableSlots = 0;
  int _txSequence = 0;

  @override
  Future<void> initialize({required String appUserId}) async {}

  @override
  Future<BillingEntitlements> getEntitlements() async {
    return BillingEntitlements(
      isPro: _isPro,
      extraBinderCredits: _extraCredits,
      availableSlots: _availableSlots,
    );
  }

  @override
  Future<BillingPurchaseResult> purchaseProduct(
    BillingProductId product,
  ) async {
    _txSequence += 1;
    if (product.isSubscription) {
      _isPro = true;
    } else if (product == BillingProductId.singleSheet ||
        product == BillingProductId.packFiveSheets ||
        product == BillingProductId.packTenSheets) {
      _availableSlots += product.slots;
    } else if (product == BillingProductId.packThreeBinders) {
      _extraCredits += 3;
    } else {
      _extraCredits += 1;
    }
    return BillingPurchaseResult(
      success: true,
      productId: product.productId,
      transactionId: 'mock_tx_$_txSequence',
    );
  }

  @override
  Future<BillingEntitlements> restorePurchases() => getEntitlements();
}
