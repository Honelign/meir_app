import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  const AppName({Key? key, required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: 'Ha',   //first part
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Color(0xffADD8E6)),
            children: <TextSpan>[
              TextSpan(
                  text: 'Rav ',  //second part
                  style:
                  TextStyle(fontFamily: 'Poppins', color: Color(0xff00008B))),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text: 'Meir',   //first part
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Color(0xffADD8E6)),
            children: <TextSpan>[
              TextSpan(
                  text: 'Eliyahu',  //second part
                  style:
                  TextStyle(fontFamily: 'Poppins', color: Color(0xff00008B))),
            ],
          ),
        ),
      ],
    );
  }
}
