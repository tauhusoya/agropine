import 'package:cloud_firestore/cloud_firestore.dart';

/// Pagination state holder
class PaginationState<T> {
  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final bool isLoading;
  final String? error;

  PaginationState({
    required this.items,
    required this.hasMore,
    this.lastDocument,
    this.isLoading = false,
    this.error,
  });

  /// Create a copy with updates
  PaginationState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    bool? isLoading,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Service for handling pagination in Firestore queries
class PaginationService {
  static const int defaultPageSize = 20;

  /// Get first page of documents
  static Future<PaginationState<DocumentSnapshot>> getFirstPage(
    Query<Map<String, dynamic>> query, {
    int pageSize = defaultPageSize,
  }) async {
    try {
      final snapshot = await query.limit(pageSize + 1).get();
      final docs = snapshot.docs;

      final hasMore = docs.length > pageSize;
      final items = hasMore ? docs.sublist(0, pageSize) : docs;
      final lastDocument = items.isNotEmpty ? items.last : null;

      return PaginationState(
        items: items,
        hasMore: hasMore,
        lastDocument: lastDocument,
      );
    } catch (e) {
      return PaginationState(
        items: [],
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// Get next page of documents
  static Future<PaginationState<DocumentSnapshot>> getNextPage(
    Query<Map<String, dynamic>> query,
    DocumentSnapshot? lastDocument, {
    int pageSize = defaultPageSize,
  }) async {
    try {
      if (lastDocument == null) {
        return PaginationState(
          items: [],
          hasMore: false,
          error: 'Last document is null',
        );
      }

      final snapshot = await query
          .startAfterDocument(lastDocument)
          .limit(pageSize + 1)
          .get();

      final docs = snapshot.docs;
      final hasMore = docs.length > pageSize;
      final items = hasMore ? docs.sublist(0, pageSize) : docs;
      final nextLastDocument = items.isNotEmpty ? items.last : null;

      return PaginationState(
        items: items,
        hasMore: hasMore,
        lastDocument: nextLastDocument,
      );
    } catch (e) {
      return PaginationState(
        items: [],
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  /// Stream all documents with pagination
  static Stream<PaginationState<DocumentSnapshot>> streamPaginatedDocuments(
    Query<Map<String, dynamic>> query, {
    int pageSize = defaultPageSize,
  }) {
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      final hasMore = docs.length > pageSize;
      final items = hasMore ? docs.sublist(0, pageSize) : docs;
      final lastDocument = items.isNotEmpty ? items.last : null;

      return PaginationState(
        items: items,
        hasMore: hasMore,
        lastDocument: lastDocument,
      );
    });
  }

  /// Convert snapshot to typed list
  static List<T> mapSnapshotsToList<T>(
    List<DocumentSnapshot> snapshots,
    T Function(DocumentSnapshot) mapper,
  ) {
    return snapshots.map(mapper).toList();
  }

  /// Combine two pages
  static PaginationState<T> combinePaginationStates<T>(
    PaginationState<T> first,
    PaginationState<T> second,
  ) {
    return PaginationState(
      items: [...first.items, ...second.items],
      hasMore: second.hasMore,
      lastDocument: second.lastDocument,
    );
  }
}
