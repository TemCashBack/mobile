import 'package:flutter/material.dart';

class DriveToButton extends StatelessWidget {
  const DriveToButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.title});
  final GestureTapCallback onPressed;
  final Icon icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        print("Botão com imagem clicado!");
      },
      child: Image.asset(
        title, // Certifique-se de que a imagem está no diretório assets
        width: 50,
        height: 50,
      ),
    );
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //       backgroundColor: primaryThemeColor, minimumSize: Size.fromHeight(40)),
    //   onPressed: onPressed,
    //   child: Padding(
    //     padding: EdgeInsets.all(10.0),
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         icon,
    //         SizedBox(
    //           width: 10.0,
    //         ),
    //         Text(
    //           title,
    //           maxLines: 1,
    //           style: TextStyle(color: Colors.white),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
