import 'package:go_router/go_router.dart';
import 'package:slotr_app/core/error/config_error_page.dart';
import 'package:slotr_app/features/bookings/presentation/pages/bookings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BookingsPage(),
    ),
    GoRoute(
      path: '/config-error',
      builder: (context, state) {
        final error = state.extra as String?;
        return ConfigErrorPage(errorMessage: error);
      },
    ),
  ],
);
