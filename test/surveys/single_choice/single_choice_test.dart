import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pal_video/surveys/single_choice/single_choice.dart';
import 'package:pal_video/surveys/single_choice/single_choice_model.dart';

void main() {
  testWidgets(
    '''
    create a form with question and 4 available response, 
    tap on first choice
    => trigger onChoice function
    ''',
    (WidgetTester tester) async {
      Choice? tapedChoice;
      var app = MaterialApp(
        home: Scaffold(
          body: SingleChoiceForm(
            question: 'my question lorem ipsum lorem',
            choices: const [
              Choice(code: 'a', text: 'lorem A'),
              Choice(code: 'b', text: 'lorem B'),
              Choice(code: 'c', text: 'lorem C'),
              Choice(code: 'd', text: 'lorem D'),
            ],
            onTap: (_, choice) => tapedChoice = choice,
          ),
        ),
      );
      await tester.pumpWidget(app);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('my question lorem ipsum lorem'), findsOneWidget);
      expect(find.text('lorem A'), findsOneWidget);
      expect(find.text('lorem B'), findsOneWidget);
      expect(find.text('lorem C'), findsOneWidget);
      expect(find.text('lorem D'), findsOneWidget);
      // tap on choice A and check onTap is triggered with it
      await tester.tap(find.text('lorem A'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tapedChoice!.code, equals('a'));
    },
  );
}
