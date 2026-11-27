import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/models/report_model.dart';
import '../../../core/services/billing_service.dart';
import '../../profile/data/report_repository.dart';
import '../data/mock_binder_repository.dart';
import '../data/repositories/binder_repository.dart';

int slotsPerSheetForFormat(String gridFormat) {
  return switch (gridFormat) {
    '2x2' => 4,
    '4x3' => 12,
    _ => 9,
  };
}

int gridCrossAxisCountForFormat(String gridFormat) {
  return switch (gridFormat) {
    '2x2' => 2,
    '4x3' => 4,
    _ => 3,
  };
}

final binderRepositoryProvider = Provider<BinderRepository>(
  (ref) => MockBinderRepository(),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => MockReportRepository(),
);

final billingServiceProvider = Provider<BillingService>(
  (ref) => MockBillingService(),
);

final activeProfileProvider = FutureProvider<ProfileModel>(
  (ref) => ref.watch(binderRepositoryProvider).getActiveProfile(),
);

final bindersProvider = FutureProvider<List<BinderModel>>(
  (ref) => ref.watch(binderRepositoryProvider).getBinders(),
);

final binderProvider = FutureProvider.family<BinderModel?, String>(
  (ref, binderId) => ref.watch(binderRepositoryProvider).getBinder(binderId),
);

final publicBinderProvider = FutureProvider.family<BinderModel?, String>(
  (ref, binderId) =>
      ref.watch(binderRepositoryProvider).getPublicBinder(binderId),
);

final binderItemsProvider = FutureProvider.family<List<ItemModel>, String>(
  (ref, binderId) => ref.watch(binderRepositoryProvider).getItems(binderId),
);

final reportsProvider = FutureProvider<List<ReportModel>>(
  (ref) => ref.watch(reportRepositoryProvider).getReports(),
);

final trashedItemsProvider = FutureProvider<List<TrashedItemRecord>>(
  (ref) => ref.watch(binderRepositoryProvider).getTrashedItems(),
);

class PortfolioValuation {
  const PortfolioValuation({
    required this.totalItems,
    required this.totalValue,
    this.totalValueWithCost = 0,
    this.unverifiedApiItems = 0,
    this.costBasis = 0,
    this.slabsCount = 0,
    this.tradeCount = 0,
  });

  final int totalItems;
  final double totalValue;
  final double totalValueWithCost;
  final int unverifiedApiItems;
  final double costBasis;
  final int slabsCount;
  final int tradeCount;

  double get netRoi => costBasis > 0 ? totalValueWithCost - costBasis : 0;

  double get roiPercent => costBasis > 0 ? (netRoi / costBasis) * 100 : 0;
}

final portfolioValuationProvider = FutureProvider<PortfolioValuation>((
  ref,
) async {
  final binders = await ref.watch(bindersProvider.future);
  var verifiedItems = 0;
  var unverifiedApi = 0;
  var totalValue = 0.0;
  var totalValueWithCost = 0.0;
  var costBasis = 0.0;
  var slabsCount = 0;
  var tradeCount = 0;

  for (final binder in binders) {
    final items = await ref.watch(binderItemsProvider(binder.id).future);
    for (final item in items) {
      if (!item.isPhysicallyVerified) {
        unverifiedApi++;
        continue;
      }
      verifiedItems++;
      final price = item.estimatedPrice ?? 0;
      totalValue += price;
      if (item.purchaseCost != null) {
        costBasis += item.purchaseCost!;
        totalValueWithCost += price;
      }
      if (item.hasSlab) {
        slabsCount++;
      }
      if (item.tradeStatus == ItemTradeStatus.forTrade ||
          item.tradeStatus == ItemTradeStatus.forSale) {
        tradeCount++;
      }
    }
  }
  return PortfolioValuation(
    totalItems: verifiedItems,
    totalValue: totalValue,
    totalValueWithCost: totalValueWithCost,
    unverifiedApiItems: unverifiedApi,
    costBasis: costBasis,
    slabsCount: slabsCount,
    tradeCount: tradeCount,
  );
});

final itemProvider =
    FutureProvider.family<ItemModel?, ({String binderId, String itemId})>((
      ref,
      params,
    ) async {
      final items = await ref.watch(
        binderItemsProvider(params.binderId).future,
      );
      for (final item in items) {
        if (item.id == params.itemId) {
          return item;
        }
      }
      return null;
    });

final publicItemProvider =
    FutureProvider.family<ItemModel?, ({String binderId, String itemId})>((
      ref,
      params,
    ) async {
      final binder = await ref.watch(
        publicBinderProvider(params.binderId).future,
      );
      if (binder == null) {
        return null;
      }
      final items = await ref.watch(
        binderItemsProvider(params.binderId).future,
      );
      for (final item in items) {
        if (item.id == params.itemId) {
          return item;
        }
      }
      return null;
    });
