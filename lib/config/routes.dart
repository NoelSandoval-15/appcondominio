import '../features/dashboard/presentation/dashboard_guardia_view.dart';
import '../features/dashboard/presentation/dashboard_residente_view.dart';
import '../features/auth/presentation/login_view.dart';
import '../features/auth/presentation/register_view.dart';
import '../features/splash/presentation/splash_view.dart';
import 'package:flutter/material.dart';
import '../features/residente/presentation/generar_qr_view.dart';
import '../features/guardia/presentation/escanear_qr_view.dart';
import '../../features/residente/presentation/avisos_view.dart';
import '../../features/residente/presentation/pagos_view.dart';




final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashView(),
  '/login': (context) => const LoginView(),
  '/register': (context) => const RegisterView(),
  '/dashboard_guardia': (context) => const DashboardGuardiaView(),
  '/dashboard_residente': (context) => const DashboardResidenteView(),
  '/generar_qr': (context) => const GenerarQRView(),
  '/escanear_qr': (context) => const EscanearQRView(),
  '/avisos': (context) => const AvisosView(),
  '/pagos': (context) => const PagosView(),

};

