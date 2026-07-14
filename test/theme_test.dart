import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porto_mobile/src/ui/theme/colors.dart';
import 'package:porto_mobile/src/ui/theme/typography.dart';
import 'package:porto_mobile/src/ui/theme/spacing.dart';

void main() {
  test('color tokens', () {
    expect(AppColors.brand, const Color(0xFFEC6530));
    expect(AppColors.palette.length, 6);
    expect(AppColors.gain, const Color(0xFF1E9396));
  });

  test('spacing & radii tokens', () {
    expect(AppSpacing.page, 28);
    expect(AppRadii.modal, 24);
  });

  test('typography tokens', () {
    expect(AppType.fontFamily, 'Anuphan');
    expect(AppType.display.fontWeight, FontWeight.w700);
  });

  testWidgets('MaterialApp with theme tokens pumps without error',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: AppType.fontFamily,
      ),
      home: const Scaffold(body: SizedBox()),
    ));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
