import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).accentColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Page not found :-(",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center),
          IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: 70.0,
              onPressed: () => Navigator.of(context).pop(false))
        ],
      ),
    );
  }
}
