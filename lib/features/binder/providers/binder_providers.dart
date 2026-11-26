import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/models/report_model.dart';
import '../../../core/services/billing_service.dart';
import '../../profile/data/report_repository.dart';
import '../data/mock_binder_repository.dart';
import '../data/repositories/binder_repository.dart';

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

class PortfolioValuation {
  const PortfolioValuation({
    required this.totalItems,
    required this.totalValue,
  });

  final int totalItems;
  final double totalValue;
}

final portfolioValuationProvider = FutureProvider<PortfolioValuation>((
  ref,
) async {
  final binders = await ref.watch(bindersProvider.future);
  var totalItems = 0;
  var totalValue = 0.0;
  for (final binder in binders) {
    final items = await ref.watch(binderItemsProvider(binder.id).future);
    totalItems += items.length;
    for (final item in items) {
      totalValue += item.estimatedPrice ?? 0;
    }
  }
  return PortfolioValuation(totalItems: totalItems, totalValue: totalValue);
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
