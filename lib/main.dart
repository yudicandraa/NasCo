import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watermelon_sound/features/presentation/bloc/prediction_bloc.dart';
import 'package:watermelon_sound/injection_container.dart';
import 'features/presentation/pages/home_page.dart';

void main() {
  injectionLocatorSetup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => locator<PredictionBloc>(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: const HomePage(),
      ),
    );
  }
}
