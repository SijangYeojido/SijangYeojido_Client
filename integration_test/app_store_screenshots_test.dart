import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sijangyeojido_client/providers/auth_provider.dart';
import 'package:sijangyeojido_client/providers/app_data_provider.dart';
import 'package:sijangyeojido_client/screens/auth/login_screen.dart';
import 'package:sijangyeojido_client/screens/main_scaffold.dart';
import 'package:sijangyeojido_client/services/notification_service.dart';
import 'package:sijangyeojido_client/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
    await NotificationService.instance.initialize();
  });

  group('App Store screenshots', () {
    testWidgets('capture ten iPhone screenshots', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.instance;
      binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

      final authProvider = AuthProvider();
      final appDataProvider = AppDataProvider();
      await authProvider.resetLocalDataForFreshRun();
      await authProvider.restoreSession();

      Future<void> capture(String name) async {
        await binding.convertFlutterSurfaceToImage();
        await binding.takeScreenshot(name);
        await _wait(tester, milliseconds: 400);
      }

      Future<void> tapLabelOrText(String label, String text, {int seconds = 3}) async {
        final labelFinder = find.bySemanticsLabel(label);
        if (labelFinder.evaluate().isNotEmpty) {
          await tester.ensureVisible(labelFinder);
          await tester.tap(labelFinder);
        } else {
          await _waitForText(tester, text);
          await tester.ensureVisible(find.text(text).first);
          await tester.tap(find.text(text).first);
        }
        await _wait(tester, seconds: seconds);
      }

      Future<void> goBack({int seconds = 2}) async {
        final back = find.byIcon(Icons.arrow_back_ios_new_rounded);
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back.first);
        } else {
          final navigator = tester.state<NavigatorState>(find.byType(Navigator));
          navigator.pop();
        }
        await _wait(tester, seconds: seconds);
      }

      Future<void> scrollDown({double offset = 900}) async {
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isEmpty) return;
        await tester.drag(scrollables.first, Offset(0, -offset));
        await _wait(tester, seconds: 1);
      }

      Future<void> scrollToTop() async {
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isEmpty) return;
        for (var i = 0; i < 4; i += 1) {
          await tester.drag(scrollables.first, const Offset(0, 900));
          await tester.pump(const Duration(milliseconds: 250));
        }
      }

      Future<void> ensureOnMarketHub() async {
        if (find.bySemanticsLabel('market-action-시장 지도').evaluate().isNotEmpty) {
          return;
        }
        if (find.bySemanticsLabel('tab-홈').evaluate().isNotEmpty) {
          await tapLabelOrText('tab-홈', '홈', seconds: 2);
        }
        await tapLabelOrText('home-market-card 신원시장', '신원시장', seconds: 3);
      }

      Future<void> tapSemantics(String label, {int seconds = 3}) async {
        await _waitForLabel(tester, label, timeoutSeconds: 30);
        await tester.tap(find.bySemanticsLabel(label));
        await _wait(tester, seconds: seconds);
      }
      Future<void> tapFirstStoreCard({int seconds = 3}) async {
        await scrollDown();
        final end = DateTime.now().add(const Duration(seconds: 30));
        while (DateTime.now().isBefore(end)) {
          await tester.pump(const Duration(milliseconds: 300));
          final cards = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.label?.startsWith('store-card-') ?? false),
          );
          if (cards.evaluate().isNotEmpty) {
            await tester.ensureVisible(cards.first);
            await tester.tap(cards.first, warnIfMissed: false);
            await _wait(tester, seconds: seconds);
            return;
          }
          await scrollDown(offset: 500);
        }
        fail('Could not find any store card on the market hub screen.');
      }

      Widget appShell(Widget home) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider.value(
              value: NotificationService.instance,
            ),
            ChangeNotifierProvider.value(value: appDataProvider),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: home,
          ),
        );
      }

      await tester.pumpWidget(appShell(const LoginScreen()));
      await _wait(tester, seconds: 2);
      await capture('01_login');

      final screenshotEmail = 'screenshots@sijangyeojido.com';
      const screenshotPassword = 'ExhibitPass2026!';
      final loggedIn =
          await authProvider.registerWithEmail(
            name: '전시 사용자',
            email: screenshotEmail,
            password: screenshotPassword,
            role: UserRole.customer,
          ) ||
          await authProvider.loginWithEmail(
            email: screenshotEmail,
            password: screenshotPassword,
          );
      expect(loggedIn, isTrue);

      await tester.pumpWidget(appShell(const MainScaffold()));
      await _waitForText(tester, '신원시장', timeoutSeconds: 30);
      await scrollDown(offset: 500);
      await _wait(tester, seconds: 2);
      await capture('02_home');

      await tapLabelOrText('home-market-card 신원시장', '신원시장');
      await capture('03_market_hub');

      await tapFirstStoreCard();
      await capture('04_store_detail');

      await scrollDown(offset: 700);
      await capture('05_store_products');

      await goBack();
      await ensureOnMarketHub();
      await tapSemantics('market-action-시장 지도');
      await capture('06_market_map');

      await goBack();
      await ensureOnMarketHub();
      await tapSemantics('market-action-쿠폰 받기');
      await capture('07_coupons');

      await goBack();
      await ensureOnMarketHub();
      await goBack();
      await tapLabelOrText('tab-탐색', '탐색');
      await capture('08_explore');

      await tapLabelOrText('tab-마이', '마이');
      await capture('09_profile');

      await tapLabelOrText('tab-홈', '홈');
      await scrollToTop();
      await tapLabelOrText('home-search', '시장명, 지역, 점포명, 품목 검색');
      await tester.enterText(find.bySemanticsLabel('global-search-field'), '신원');
      await _wait(tester, seconds: 2);
      await capture('10_search_results');
    });
  });
}

Future<void> _wait(
  WidgetTester tester, {
  int seconds = 0,
  int milliseconds = 0,
}) async {
  final end = DateTime.now().add(
    Duration(seconds: seconds, milliseconds: milliseconds),
  );
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _waitForText(
  WidgetTester tester,
  String text, {
  int timeoutSeconds = 20,
}) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (find.text(text).evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for text: $text');
}

Future<void> _waitForLabel(
  WidgetTester tester,
  String label, {
  int timeoutSeconds = 20,
}) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (find.bySemanticsLabel(label).evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for semantics label: $label');
}
