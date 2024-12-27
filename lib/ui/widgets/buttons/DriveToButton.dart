import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/ui/theme/colors.dart';

class DriveToButton extends StatelessWidget {
  const DriveToButton({super.key, required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: defaultTheme, minimumSize: Size.fromHeight(40)),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.route,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              "Traçar rota até a empresa",
              maxLines: 1,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
