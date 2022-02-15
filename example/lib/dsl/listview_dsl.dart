//
//  listview_dsl
//  Created by tom on 2022/2/15.
//  Copyright ©xcar. All rights reserved.
//

import 'package:flutter/material.dart';

class ListViewDSL extends StatefulWidget {
  const ListViewDSL({Key? key}) : super(key: key);

  @override
  _ListViewDSLState createState() => _ListViewDSLState();
}

class _ListViewDSLState extends State<ListViewDSL> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'ListViewDSL',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            child: const Text('Hellow World',
                style: TextStyle(color: Colors.white, fontSize: 18)),
            color: Colors.lightBlue.shade300,
            height: 45,
          );
        },
        itemCount: 50,
      ),
    );
  }
}
