import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/ui/theme/colors.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key, required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          fixedSize: Size(200, 45),
          foregroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: Colors.transparent,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.userPen,
              color: secondaryThemeColor,
              size: 18,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              "Não tenho cadastro",
              maxLines: 1,
              style: TextStyle(color: secondaryThemeColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
