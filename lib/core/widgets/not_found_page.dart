import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../error/failure.dart';
import '../router/app_router.dart';
import 'error_view.dart';

/// Shown by go_router for unknown paths (e.g. a broken deep link).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không tìm thấy trang')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ErrorView(failure: NotFoundFailure('Đường dẫn không tồn tại hoặc đã bị gỡ.')),
          TextButton(onPressed: () => context.go(AppRoutes.services), child: const Text('Về trang dịch vụ')),
        ],
      ),
    );
  }
}
