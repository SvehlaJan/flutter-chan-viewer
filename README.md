# Flutter 4chan viewer

Playground project to learn Flutter.

App consumes and shows content from 4chan. Be aware that the content can be extreme and NSFW! There
is a filter in settings and it should stay turned ON.

Currently works on Android (iOS should too). MacOs is working partially.

App is built on BLoC architecture https://bloclibrary.dev/ .

On-device database is built with Drift persistence library https://drift.simonbinder.eu/ .
To generate the DB code, use `flutter pub run build_runner watch`.
