import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Importe seus ViewModels
import 'viewmodels/authViewModel.dart';
import 'viewmodels/guestViewModel.dart';
import 'viewmodels/organizerViewModel.dart';
import 'viewmodels/eventViewModel.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. Adicione esta linha
// Importe suas Views
import 'views/homeView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  // APENAS UMA INICIALIZAÇÃO AQUI (A versão hardcoded para a Web):
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAVSm0XiOyPv-TLHbReY9HldbxKA1qjebk',
      appId: '1:631991508995:web:256c00844feb52b017ae36',
      messagingSenderId: '631991508995',
      projectId: 'gather-app-f9a4a',
      authDomain: 'gather-app-f9a4a.firebaseapp.com',
      storageBucket: 'gather-app-f9a4a.firebasestorage.app',
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => GuestViewModel()),
        ChangeNotifierProvider(create: (_) => OrganizerViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
      ],
      child: const GatherApp(),
    ),
  );
}

class GatherApp extends StatelessWidget {
  const GatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF161730),
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF161730),
          secondary: const Color(0xFF00D1FF),
        ),
        fontFamily: 'Inter',
      ),
      home: const HomeView(),
    );
  }
}
