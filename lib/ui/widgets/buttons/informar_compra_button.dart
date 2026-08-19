import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/ui/theme/colors.dart';

class InformarCompraButton extends StatelessWidget {
  const InformarCompraButton({super.key, required this.onPressed});
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryThemeColor,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(40),
      ),
      onPressed: onPressed,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.cartShopping,
              size: 18,
            ),
            SizedBox(width: 10.0),
            Text(
              'Informar compra',
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
