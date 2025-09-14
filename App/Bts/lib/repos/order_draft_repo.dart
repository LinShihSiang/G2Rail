import '../models/order_draft.dart';

abstract class OrderDraftRepo {
  Future<void> save(OrderDraft draft);
  Future<OrderDraft?> getLatest();
  Future<void> clear();
}

class InMemoryOrderDraftRepo implements OrderDraftRepo {
  static OrderDraft? _cachedDraft;

  @override
  Future<void> save(OrderDraft draft) async {
    _cachedDraft = draft;
  }

  @override
  Future<OrderDraft?> getLatest() async {
    return _cachedDraft;
  }

  @override
  Future<void> clear() async {
    _cachedDraft = null;
  }
}