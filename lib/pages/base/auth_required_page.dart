import 'package:flutter/material.dart';

class AuthRequiredPage extends StatelessWidget {
  AuthRequiredPage();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Please, authenticate",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center),
          IconButton(
              icon: Icon(Icons.fingerprint),
              iconSize: 70.0,
              onPressed: () => null)
        ],
      ),
    );
  }
}
