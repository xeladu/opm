import 'package:appwrite/appwrite.dart';
import 'package:open_password_manager/shared/domain/repositories/salt_repository.dart';

class AppwriteSaltRepositoryImpl implements SaltRepository {
  final Client client;
  final String databaseId;
  final String collectionId;
  late Databases _db;

  AppwriteSaltRepositoryImpl({
    required this.client,
    required this.databaseId,
    required this.collectionId,
  }) {
    _db = Databases(client);
  }

  @override
  Future<String?> getUserSalt(String userId) async {
    try {
      print(
        'Getting salt for userId: $userId (using as document ID) in database: $databaseId, collection: $collectionId',
      );

      // Use the userId directly as the document ID
      final document = await _db.getDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: userId,
      );

      final saltValue = document.data['salt'] as String?;
      print('Retrieved salt: $saltValue');
      return saltValue;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        print('No salt found for user $userId (document not found)');
        return null;
      }
      print('Error getting user salt: ${e.message}, code: ${e.code}');
      return null;
    } catch (e) {
      print('Error getting user salt: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<void> saveUserSalt(String userId, String salt) async {
    try {
      print('Saving salt for userId: $userId (using as document ID), salt: $salt');
      print('Using database: $databaseId, collection: $collectionId');

      // Let's try a super minimal approach with absolutely no extra data
      try {
        print('Testing minimal document creation...');
        
        // Try with a simple test document first
        final testResult = await _db.createDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: 'test-${DateTime.now().millisecondsSinceEpoch}', // Use timestamp as test ID
          data: {
            'salt': 'test-salt-value',
          },
          permissions: [
            Permission.read(Role.user(userId)),
            Permission.update(Role.user(userId)),
            Permission.delete(Role.user(userId)),
          ],
        );
        print('Test document created successfully: ${testResult.$id}');
        
        // If test works, delete it and try with real data
        await _db.deleteDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: testResult.$id,
        );
        print('Test document deleted successfully');
        
        // Now try with real user data
        final result = await _db.createDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: userId,
          data: {
            'salt': salt,
          },
          permissions: [
            Permission.read(Role.user(userId)),
            Permission.update(Role.user(userId)),
            Permission.delete(Role.user(userId)),
          ],
        );
        print('SUCCESS: Created real salt document with ID: ${result.$id}');
        return;
      } on AppwriteException catch (e) {
        print('AppwriteException during create: ${e.message}, code: ${e.code}, type: ${e.type}');
        print('Full response: ${e.response}');
        
        if (e.code == 409) {
          print('Document exists, trying update...');
          try {
            await _db.updateDocument(
              databaseId: databaseId,
              collectionId: collectionId,
              documentId: userId,
              data: {
                'salt': salt,
              },
            );
            print('SUCCESS: Updated existing salt document');
            return;
          } on AppwriteException catch (updateE) {
            print('Update failed: ${updateE.message}, code: ${updateE.code}');
            print('Update response: ${updateE.response}');
            rethrow;
          }
        }
        rethrow;
      } catch (e) {
        print('Non-Appwrite exception: $e, type: ${e.runtimeType}');
        print('This suggests an SDK or environment issue');
        rethrow;
      }
    } catch (e) {
      print('Error saving user salt: $e');
      print('Error type: ${e.runtimeType}');
      
      // Let's also try to get some info about the collection itself
      try {
        print('Attempting to list any documents to test collection access...');
        final listResult = await _db.listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: [Query.limit(1)],
        );
        print('Collection is accessible, has ${listResult.documents.length} documents');
        if (listResult.documents.isNotEmpty) {
          print('Sample document structure: ${listResult.documents.first.data}');
        }
      } catch (listError) {
        print('Even listing documents fails: $listError');
      }
      
      rethrow;
    }
  }
}
