import 'package:flutter/material.dart';
import 'package:new_admin_panel/app.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/products_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qackrunhjegacjcljwyn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhY2tydW5oamVnYWNqY2xqd3luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyMjM3MzUsImV4cCI6MjA1Mjc5OTczNX0.8cE6tVTN8YTCpC3OvMppuxVTi3L43ywP-ES_v0S7VgA',
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProductsProvider(),
      child: const AdminPanel(),
    ),
  );
}
