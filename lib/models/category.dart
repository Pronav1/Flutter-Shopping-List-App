import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  sweets,
  carbs,
  hygiene,
  convenience,
  spices,
  other
}

const categoriesColor = {
  Categories.dairy: Colors.blue,
  Categories.fruit: Colors.yellow,
  Categories.meat: Colors.red
};

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
