import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/binder_model.dart';
import '../data/mock_binder_repository.dart';
import '../data/repositories/binder_repository.dart';

final binderRepositoryProvider = Provider<BinderRepository>(
  (ref) => MockBinderRepository(),
);

final bindersProvider = FutureProvider<List<BinderModel>>(
  (ref) => ref.watch(binderRepositoryProvider).getBinders(),
);
