import 'package:flutter_test/flutter_test.dart';

import 'package:campus_update/main.dart';

void main() {
  testWidgets('welcome screen renders', (tester) async {
    await tester.pumpWidget(const CampusUpdateApp());

    expect(find.text('CAMPUS UPDATE'), findsOneWidget);
    expect(find.text('Ready to be implemented'), findsOneWidget);
  });
}
