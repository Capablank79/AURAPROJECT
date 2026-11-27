import '../../../../core/models/binder_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/models/profile_model.dart';

abstract interface class BinderRepository {
  Future<ProfileModel> getActiveProfile();

  Future<List<BinderModel>> getBinders();

  Future<BinderModel?> getBinder(String binderId);

  Future<List<ItemModel>> getItems(String binderId);

  Future<BinderModel> createBinder({
    required String title,
    required String family,
    required String collectionCode,
    String? customCollectionName,
    required bool isPublic,
    int? maxSlots,
  });

  Future<BinderModel> updateBinder({
    required String binderId,
    String? title,
    String? gridFormat,
    bool? isPublic,
  });

  Future<BinderModel> resizeBinder({
    required String binderId,
    required int newMaxSlots,
  });

  Future<BinderModel> completeBinder(String binderId);

  Future<void> deleteBinder(String binderId);

  Future<ItemModel> addItem(ItemModel item);

  Future<ItemModel> updateItem(ItemModel item);

  Future<void> swapItemPositions({
    required String binderId,
    required int fromPosition,
    required int toPosition,
  });

  Future<void> deleteItem(String itemId);

  Future<List<TrashedItemRecord>> getTrashedItems();

  Future<TrashedItemRecord?> moveItemToTrash(String itemId);

  Future<ItemModel> restoreItemFromTrash(String itemId);

  Future<void> permanentlyDeleteFromTrash(String itemId);

  Future<void> emptyTrash();

  Future<BinderModel?> getPublicBinder(String binderId);

  Future<ProfileModel> updateProfileEntitlements({
    bool? isPro,
    bool? isAdmin,
    int? extraBinderCredits,
    int? availableSlots,
  });

  Future<ProfileModel> updateProfileIdentity({
    String? displayName,
    String? tradeContact,
  });
}

class BinderRepositoryException implements Exception {
  const BinderRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BinderLimitException extends BinderRepositoryException {
  const BinderLimitException() : super('A free account can own one binder.');
}

class BinderCapacityException extends BinderRepositoryException {
  const BinderCapacityException() : super('Binder capacity exceeded.');
}

class ItemPositionException extends BinderRepositoryException {
  const ItemPositionException() : super('This binder position is occupied.');
}

class PrivateBinderException extends BinderRepositoryException {
  const PrivateBinderException() : super('This binder is not public.');
}

class CollectionMismatchException extends BinderRepositoryException {
  const CollectionMismatchException({
    required this.expectedCollectionCode,
    required this.actualCollectionCode,
  }) : super(
         'Collection mismatch: expected $expectedCollectionCode, got $actualCollectionCode.',
       );

  final String expectedCollectionCode;
  final String actualCollectionCode;
}

class InvalidCustomCollectionException extends BinderRepositoryException {
  const InvalidCustomCollectionException()
    : super('A custom collection name is required.');
}
