import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sijangyeojido_client/main.dart';
import 'package:sijangyeojido_client/providers/app_data_provider.dart';
import 'package:sijangyeojido_client/providers/auth_provider.dart';

void main() {
  testWidgets('앱 스모크 테스트 (MainScaffold 렌더링)', (tester) async {
    final authProvider = AuthProvider()
      ..login('test@example.com', '', UserRole.merchant);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider(create: (_) => AppDataProvider()),
        ],
        child: const SijangYeojidoApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pump();

    expect(find.text('대시보드'), findsOneWidget);
    expect(find.text('상품 관리'), findsOneWidget);
    expect(find.text('내 정보'), findsOneWidget);

    await tester.tap(find.text('상품 관리'));
    await tester.pump();
    expect(find.text('상품 관리'), findsWidgets);

    await tester.tap(find.text('내 정보'));
    await tester.pump();
    expect(find.text('내 정보'), findsWidgets);
  });
}
