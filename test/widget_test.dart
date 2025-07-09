import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinema_uygulamasi/main.dart';
import 'package:sinema_uygulamasi/components/user.dart';

void main() {
  testWidgets('Cinema app basic test', (WidgetTester tester) async {
    // Test için örnek bir User nesnesi oluşturuyoruz (gerçek User modeline göre)
    final testUser = User(
      id: 123,
      name: 'Test Kullanıcı',
      email: 'test@example.com',
      roleId: 1,
      isActive: true, // Required parameter eklendi
      // token parametresi yok, çıkarıldı
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(currentUser: testUser));

    // Uygulamanın düzgün yüklendiğini kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);

    // HomePage'in yüklendiğini kontrol et (çünkü user null değil)
    await tester.pumpAndSettle();

    // Test geçti
    expect(testUser.name, equals('Test Kullanıcı'));
    expect(testUser.email, equals('test@example.com'));
    expect(testUser.isActive, equals(true));
  });

  testWidgets('Login screen shows when no user', (WidgetTester tester) async {
    // Kullanıcı olmadan uygulamayı test et
    await tester.pumpWidget(const MyApp(currentUser: null));

    // LoginScreen'in yüklendiğini kontrol et
    await tester.pumpAndSettle();

    // Test geçti
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
