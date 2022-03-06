import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ThemeAndMaterialWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _materialAppBloc();

  /// Widget wrapper to enclose switching dark/light mode themes of the MaterialApp
  Widget _materialAppBloc() => MaterialApp.router(
        routeInformationParser: Modular.routeInformationParser,
        routerDelegate: Modular.routerDelegate,
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
}
