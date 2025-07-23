import 'package:flutter/material.dart';

Widget miniCard({
  required String title,
  required String value,
  required IconData icon,
  required double width,
  required double height,
  required double iconSize,
  required double titleSize,
  required double valueSize,
  Color? backgroundColor,
  Color? textColor,
  Color? iconColor,
}){
  return SizedBox(
    width: width,
    height: height,
    child: Card(
      color: backgroundColor ?? Colors.white,
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.black,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}