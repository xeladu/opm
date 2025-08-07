import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/features/vault/infrastructure/repositories/import_repository_impl.dart';

void main() {
  group('ImportRepositoryImpl', () {
    final repo = ImportRepositoryImpl();

    group("1Password", () {
      test('1Password valid CSV', () async {
        final csv =
            '"Title","Website","Username","Password","Notes"\n'
            '"Entry1","http://site.com","user1","pass1","note1"';
        final result = await repo.importFrom1Password(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry1');
        expect(entry.username, 'user1');
        expect(entry.password, 'pass1');
        expect(entry.urls, ['http://site.com']);
        expect(entry.comments, 'note1');
      });

      test('1Password partially valid CSV', () async {
        final csv =
            '"Title","Website","Username","Password","Notes"\n'
            '"Entry2","","user2","",""';
        final result = await repo.importFrom1Password(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry2');
        expect(entry.username, 'user2');
        expect(entry.password, '');
        expect(entry.urls, <String>[]);
        expect(entry.comments, '');
      });

      test('1Password invalid CSV', () async {
        final csv =
            '"Title","Website","Username","Password","Notes"\n'
            '"Too Short","user1"';
        final result = await repo.importFrom1Password(csv);
        expect(result, isEmpty);
      });

      test('1Password empty CSV', () async {
        final csv = '';
        final result = await repo.importFrom1Password(csv);
        expect(result, isEmpty);
      });
    });

    group("Bitwarden", () {
      test('Bitwarden valid CSV', () async {
        final csv =
            '"name","login_username","login_password","login_uri","notes"\n'
            '"Entry3","user3","pass3","http://site.com","note3"';
        final result = await repo.importFromBitwarden(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry3');
        expect(entry.username, 'user3');
        expect(entry.password, 'pass3');
        expect(entry.urls, ['http://site.com']);
        expect(entry.comments, 'note3');
      });

      test('Bitwarden partially valid CSV', () async {
        final csv =
            '"name","login_username","login_password","login_uri","notes"\n'
            '"Entry4","user4","","",""';
        final result = await repo.importFromBitwarden(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry4');
        expect(entry.username, 'user4');
        expect(entry.password, '');
        expect(entry.urls, <String>[]);
        expect(entry.comments, '');
      });

      test('Bitwarden invalid CSV', () async {
        final csv =
            '"name","login_username","login_password","login_uri","notes"\n'
            '"Too Short","user3"';
        final result = await repo.importFromBitwarden(csv);
        expect(result, isEmpty);
      });

      test('Bitwarden empty CSV', () async {
        final csv = '';
        final result = await repo.importFromBitwarden(csv);
        expect(result, isEmpty);
      });
    });

    group("Keeper", () {
      test('Keeper valid CSV', () async {
        final csv =
            '"Title","Login","Password","Website Address","Notes"\n'
            '"Entry5","user5","pass5","http://site.com","note5"';
        final result = await repo.importFromKeeper(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry5');
        expect(entry.username, 'user5');
        expect(entry.password, 'pass5');
        expect(entry.urls, ['http://site.com']);
        expect(entry.comments, 'note5');
      });

      test('Keeper partially valid CSV', () async {
        final csv =
            '"Title","Login","Password","Website Address","Notes"\n'
            '"Entry6","user6","","",""';
        final result = await repo.importFromKeeper(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry6');
        expect(entry.username, 'user6');
        expect(entry.password, '');
        expect(entry.urls, <String>[]);
        expect(entry.comments, '');
      });

      test('Keeper invalid CSV', () async {
        final csv =
            '"Title","Login","Password","Website Address","Notes"\n'
            '"Too Short","user4"';
        final result = await repo.importFromKeeper(csv);
        expect(result, isEmpty);
      });

      test('Keeper empty CSV', () async {
        final csv = '';
        final result = await repo.importFromKeeper(csv);
        expect(result, isEmpty);
      });
    });

    group("LastPass", () {
      test('LastPass valid CSV', () async {
        final csv =
            '"url","username","password","extra","name","grouping","fav"\n'
            '"http://site.com","user7","pass7","note7","Entry7","group","0"';
        final result = await repo.importFromLastPass(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry7');
        expect(entry.username, 'user7');
        expect(entry.password, 'pass7');
        expect(entry.urls, ['http://site.com']);
        expect(entry.comments, 'note7');
      });

      test('LastPass partially valid CSV', () async {
        final csv =
            '"url","username","password","extra","name","grouping","fav"\n'
            '"","user8","","","Entry8","",""';
        final result = await repo.importFromLastPass(csv);
        expect(result, hasLength(1));
        final entry = result.first;
        expect(entry.name, 'Entry8');
        expect(entry.username, 'user8');
        expect(entry.password, '');
        expect(entry.urls, <String>[]);
        expect(entry.comments, '');
      });

      test('LastPass invalid CSV', () async {
        final csv =
            '"url","username","password","extra","name","grouping","fav"\n'
            '"Too Short","user5"';
        final result = await repo.importFromLastPass(csv);
        expect(result, isEmpty);
      });

      test('LastPass empty CSV', () async {
        final csv = '';
        final result = await repo.importFromLastPass(csv);
        expect(result, isEmpty);
      });
    });

    group("KeePass", () {
      test('KeePass valid CSV', () async {
        final csv =
            '"Account","Login Name","Password","Web Site","Comments"\n'
            '"Sample Entry Title","Greg","ycXfARD2G1AOBzLlhtbn","http://www.somepage.net","Some notes..."';
        final result = await repo.importFromKeepass(csv);

        expect(result, hasLength(1));
        final entry = result.first;

        expect(entry.name, 'Sample Entry Title');
        expect(entry.username, 'Greg');
        expect(entry.password, 'ycXfARD2G1AOBzLlhtbn');
        expect(entry.urls, ['http://www.somepage.net']);
        expect(entry.comments, 'Some notes...');
      });

      test('KeePass partially valid CSV', () async {
        final csv =
            '"Account","Login Name","Password","Web Site","Comments"\n'
            '"Entry With Missing Fields","user2","","",""';
        final result = await repo.importFromKeepass(csv);

        expect(result, hasLength(1));
        final entry = result.first;

        expect(entry.name, 'Entry With Missing Fields');
        expect(entry.username, 'user2');
        expect(entry.password, '');
        expect(entry.urls, <String>[]);
        expect(entry.comments, '');
      });

      test('KeePass invalid CSV', () async {
        final csv =
            '"Account","Login Name","Password","Web Site","Comments"\n'
            '"Too Short","user3"';
        final result = await repo.importFromKeepass(csv);

        expect(result, isEmpty);
      });

      test('KeePass empty CSV', () async {
        final csv = '';
        final result = await repo.importFromKeepass(csv);

        expect(result, isEmpty);
      });
    });
  });
}
