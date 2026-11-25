import '../../../core/constants/app_constants.dart';
import '../../../core/models/binder_model.dart';
import 'repositories/binder_repository.dart';

class MockBinderRepository implements BinderRepository {
  @override
  Future<List<BinderModel>> getBinders() async {
    return [
      BinderModel(
        id: '00000000-0000-0000-0000-000000000001',
        userId: '00000000-0000-0000-0000-000000000010',
        title: 'Aura Collection',
        category: 'custom',
        gridFormat: '3x3',
        maxSlots: AppConstants.standardBinderSlots,
        isFreeTier: true,
        theme: 'obsidian_gold',
        isPublic: false,
        createdAt: DateTime.utc(2026),
      ),
    ];
  }
}
