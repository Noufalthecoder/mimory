import 'package:flutter/material.dart';

class BookPageData {
  final String id;
  final String title;
  final int pageNumber;
  final Widget content;

  const BookPageData({
    required this.id,
    required this.title,
    required this.pageNumber,
    required this.content,
  });
}
