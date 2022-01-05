import 'package:flutter/material.dart';

typedef OnTapChoice = void Function(Choice choice);

class SingleChoiceForm extends StatefulWidget {
  final String question;
  final List<Choice> choices;
  final OnTapChoice onTap;

  const SingleChoiceForm({
    Key? key,
    required this.question,
    required this.choices,
    required this.onTap,
  }) : super(key: key);

  @override
  _SingleChoiceFormState createState() => _SingleChoiceFormState();
}

class _SingleChoiceFormState extends State<SingleChoiceForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(flex: 1),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                widget.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),
            ),
            const Flexible(
              flex: 0,
              child: SizedBox(height: 12),
              fit: FlexFit.loose,
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) => ChoiceWidget.pal(
                  choice: widget.choices[index],
                  onTap: widget.onTap,
                ),
                itemCount: widget.choices.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Choice {
  final String id;
  final String text;

  const Choice({
    required this.id,
    required this.text,
  });
}

class ChoiceWidget extends StatelessWidget {
  final Choice choice;
  final Color bgColor, onTapColor;
  final OnTapChoice onTap;

  const ChoiceWidget(
    this.choice, {
    Key? key,
    required this.bgColor,
    required this.onTapColor,
    required this.onTap,
  }) : super(key: key);

  factory ChoiceWidget.pal({
    required Choice choice,
    required OnTapChoice onTap,
  }) =>
      ChoiceWidget(
        choice,
        bgColor: const Color(0xFF2D3645),
        onTapColor: const Color(0xFF3E6199),
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            onTap(choice);
          });
        },
        child: Ink(
          color: bgColor,
          padding: const EdgeInsets.all(16),
          child: Text(
            choice.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
