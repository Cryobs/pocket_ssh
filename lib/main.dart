import 'package:flutter/material.dart';
import 'package:pocket_ssh/pages/template.dart';

void main() {
  runApp(const Template(pages: [
    Center(child: Text("Page 1", style: TextStyle(color: Colors.white),)),
    Center(child: Text("Page 2", style: TextStyle(color: Colors.white),)),
    Center(child: Text("Page 3", style: TextStyle(color: Colors.white),)),
    Center(child: Text("Page 4", style: TextStyle(color: Colors.white),)),
  ],));
}
