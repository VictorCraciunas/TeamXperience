import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamxperience/features/log-in/controller/log_in_controller.dart';
import 'package:teamxperience/service/last_email_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('remembers the last email, trimmed', () async {
    final store = LastEmailStore();
    expect(await store.read(), isNull);
    await store.save('  ana@email.ro ');
    expect(await store.read(), 'ana@email.ro');
  });

  test('a blank email changes nothing', () async {
    final store = LastEmailStore();
    await store.save('ana@email.ro');
    await store.save('   ');
    expect(await store.read(), 'ana@email.ro');
  });

  test('the log-in form starts with the remembered email', () async {
    await LastEmailStore().save('ana@email.ro');
    final controller = LogInController();
    await controller.prefillEmail();
    expect(controller.emailController.text, 'ana@email.ro');
  });

  test('prefilling never overwrites what was already typed', () async {
    await LastEmailStore().save('ana@email.ro');
    final controller = LogInController();
    controller.emailController.text = 'radu@email.ro';
    await controller.prefillEmail();
    expect(controller.emailController.text, 'radu@email.ro');
  });
}
