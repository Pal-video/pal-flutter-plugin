import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PalBanner extends StatelessWidget {
  const PalBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF563BFF),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Powered by",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Image(
              image: logo,
              height: 16,
              errorBuilder: (_, __, ___) => Container(),
            )
            //Image.asset("assets/logo.png", package: "pal"),
          ],
        ),
      ),
    );
  }
}

const logo = AssetImage('packages/pal_video/assets/logo.png');
