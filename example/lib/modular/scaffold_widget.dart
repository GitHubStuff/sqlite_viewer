import 'package:extensions_package/extensions_package.dart';
import 'package:flutter/material.dart';

class ScaffoldWidget extends StatefulWidget {
  ScaffoldWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ScaffoldWidget createState() => _ScaffoldWidget();
}

class _ScaffoldWidget extends ObservingStatefulWidget<ScaffoldWidget> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [],
        ),
        body: _body(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );

  Widget _body(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 3.0,
                  children: [],
                ),
              ),
            ],
          ),
        ).borderAll(Colors.blueAccent).paddingAll(3.0),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                _themeIcons(),
              ],
            ),
          ),
        ).paddingAll(3.0),
        SizedBox(height: 4),
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) => Container(),
          ),
        ),
        SizedBox(height: 72.0),
      ],
    );
  }

  Widget _themeIcons() {
    return Column(
      children: [
        Row(
          children: [],
        ),
        Row(
          children: [],
        ),
      ],
    );
  }
}
