import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  final String userName;
  final String companyTitle;
  final String? imageUrl;

  const UserCard({
    Key? key,
    required this.userName,
    required this.companyTitle,
    this.imageUrl,
  }) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        color: Colors.black,
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
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.companyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
