import 'package:flutter/material.dart';
import 'package:mediquick/mixpanel_service.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mediquick/widget/apotek/Cart_Provider.dart';
import 'package:mediquick/admin/admin_dashboard.dart';
import 'package:mediquick/apotek_role/apotek_dashboard.dart';
import 'package:mediquick/screens/splash_screen.dart';

late Mixpanel mixpanel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Format Tanggal Lokal
  await initializeDateFormatting('id_ID', null);
  await MixpanelService.init();

  // Inisialisasi Mixpanel
  mixpanel = await Mixpanel.init(
    "55e2e0b4403ef25fbf29fad03109fbd8", // ← Ganti dengan Project Token dari Mixpanel
    trackAutomaticEvents: false,
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MediQuick(),
    ),
  );
}

class MediQuick extends StatelessWidget {
  const MediQuick({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQuick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        '/admin': (context) => const AdminDashboardScreen(),
        '/apotek': (context) => const ApotekDashboardScreen(),
      },
    );
  }
}
