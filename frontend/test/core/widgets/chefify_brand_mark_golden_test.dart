import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/chefify_brand_mark.dart';

void main() {
  testWidgets('Chefify brand mark matches its golden', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ColoredBox(
          color: Color(0xFFFFFDF9),
          child: Center(child: ChefifyBrandMark(size: 96, borderRadius: 28)),
        ),
      ),
    );
    await expectLater(
      find.byType(ChefifyBrandMark),
      matchesGoldenFile('goldens/chefify_brand_mark.png'),
    );
  });
}
