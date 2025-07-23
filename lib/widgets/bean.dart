
import 'package:flutter/material.dart';

Widget bean(String value, {Color? beanColor, Color? textColor}) {
  // Use provided colors or default colors
  Color finalBeanColor = beanColor ?? Colors.yellow;
  Color finalTextColor = textColor ?? Colors.black;
  
  return Card(
    color: finalBeanColor,
    child: Padding(
      padding: const EdgeInsets.all(6.0),
      child:
        Text(
          value,
          style: TextStyle(
            color: finalTextColor,
            fontSize: 14, 
            fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}