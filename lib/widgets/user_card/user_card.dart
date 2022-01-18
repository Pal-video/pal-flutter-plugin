import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final Text userName;
  final Text companyTitle;
  final Color bgColor;
  final String? imageUrl;

  const UserCard({
    Key? key,
    required this.userName,
    required this.companyTitle,
    required this.bgColor,
    this.imageUrl,
  }) : super(key: key);

  factory UserCard.black({
    required String userName,
    required String companyTitle,
    required String? imageUrl,
  }) =>
      UserCard(
        bgColor: Colors.black,
        imageUrl: imageUrl,
        userName: Text(
          userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        companyTitle: Text(
          companyTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w200,
            fontSize: 14,
          ),
        ),
      );

  // factory UserCard.grey({
  //   required String userName,
  //   required String companyTitle,
  //   required String? imageUrl,
  // }) =>
  //     UserCard(
  //       bgColor: const Color(0xFF2D3645),
  //       imageUrl: imageUrl,
  //       userName: Text(
  //         userName,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //           fontSize: 18,
  //         ),
  //       ),
  //       companyTitle: Text(
  //         companyTitle,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w200,
  //           fontSize: 14,
  //         ),
  //       ),
  //     );

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
        color: widget.bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.imageUrl != null)
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(widget.imageUrl!),
            ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.userName,
              const SizedBox(height: 8),
              widget.companyTitle,
            ],
          )
        ],
      ),
    );
  }
}
