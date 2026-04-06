import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _bookmarks =>
      _db.collection('bookmarks');

  CollectionReference<Map<String, dynamic>> get _quizScores =>
      _db.collection('quiz_scores');

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _users.doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addBookmark({
    required String userId,
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    await _bookmarks.add({
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> bookmarksForUser(String uid) {
    return _bookmarks
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteBookmark(String bookmarkDocId) async {
    await _bookmarks.doc(bookmarkDocId).delete();
  }

  Future<void> addQuizScore({
    required String userId,
    required int score,
    required int totalQuestions,
  }) async {
    await _quizScores.add({
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> quizScoresForUser(String uid) {
    return _quizScores
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots();
  }
}

