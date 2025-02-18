import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/ui/theme/colors.dart';

class FacebookButton extends StatelessWidget {
  const FacebookButton({super.key, required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: primaryThemeColor, fixedSize: Size(200, 45)),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.facebook,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              "FACEBOOK",
              maxLines: 1,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
