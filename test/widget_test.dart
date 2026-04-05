import 'package:flutter_test/flutter_test.dart';
import 'package:message_parser/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    // On non-Android/iOS hosts the platform check in PocScreen will throw,
    // so we just verify that the widget tree can be constructed.
    await tester.pumpWidget(const MessageParserApp());
    expect(find.text('Messages'), findsAny);
  });
}
