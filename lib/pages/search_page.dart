import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final String? keyword;
  final String? tag;
  const SearchPage({super.key,this.keyword, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Text('search'),
    );
  }
}