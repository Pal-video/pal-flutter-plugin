import 'package:flutter/material.dart';

import 'single_choice_model.dart';

const successColor = Color(0xFF60E78D);

const textColor = Color(0xFF0F0F0F);

const choiceBgColor = Color(0xFFFFFFFF);

typedef OnTapChoiceWithContext = void Function(
    BuildContext context, Choice choice);

class SingleChoiceForm extends StatefulWidget {
  final String question;
  final List<Choice> choices;
  final OnTapChoiceWithContext onTap;

  const SingleChoiceForm({
    Key? key,
    required this.question,
    required this.choices,
    required this.onTap,
  }) : super(key: key);

  @override
  SingleChoiceFormState createState() => SingleChoiceFormState();
}

@visibleForTesting
class SingleChoiceFormState extends State<SingleChoiceForm>
    with SingleTickerProviderStateMixin {
  AnimationController? _animController;

  // Animation<double>? _tweenAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // _tweenAnim = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //   parent: _animController!,
    //   curve: Curves.easeOut,
    // ));
    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   _animController.forward();
    // });
  }

  @override
  void dispose() {
    if (_animController != null) {
      _animController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: [
            // const Spacer(flex: 2),
            Flexible(
              flex: 0,
              child: Text(
                widget.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const Flexible(
              flex: 0,
              child: SizedBox(height: 30),
            ),
            Wrap(
              direction: Axis.horizontal,
              spacing: 16,
              runSpacing: 16,
              children: widget.choices
                  .map(
                    (choice) => ChoiceWidget.pal(
                      choice: choice,
                      onTap: widget.onTap,
                    ),
                  )
                  .toList(),
            ),
            const Flexible(
              flex: 0,
              child: SizedBox(height: 72),
            ),
          ],
        ),
      ),
    );
  }
}

class ChoiceWidget extends StatelessWidget {
  final Choice choice;
  final Color bgColor, onTapColor;
  final OnTapChoiceWithContext onTap;

  const ChoiceWidget(
    this.choice, {
    Key? key,
    required this.bgColor,
    required this.onTapColor,
    required this.onTap,
  }) : super(key: key);

  factory ChoiceWidget.pal({
    required Choice choice,
    required OnTapChoiceWithContext onTap,
  }) =>
      ChoiceWidget(
        choice,
        bgColor: choiceBgColor,
        onTapColor: successColor,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: onTapColor,
        splashColor: onTapColor,
        onTap: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            onTap(context, choice);
          });
        },
        child: LayoutBuilder(builder: (context, constraints) {
          return Ink(
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              color: bgColor,
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              choice.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          );
        }),
      ),
    );
  }
}
