import '../../../../core/models/binder_model.dart';

abstract interface class BinderRepository {
  Future<List<BinderModel>> getBinders();
}
