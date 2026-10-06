import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/service_providers.dart';
import '../widgets/category_bar.dart';
import '../widgets/service_card.dart';

class ServiceListPage extends ConsumerWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: const Text('Dịch vụ'),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            sliver: SliverToBoxAdapter(child: CategoryBar()),
          ),
          servicesAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Đã có lỗi: $error')),
            ),
            data: (services) {
              if (services.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Chưa có dịch vụ nào')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.86, // width / height of each card
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final item = services[index];
                    return ServiceCard(
                      service: item,
                      onTap: () =>
                          context.push(AppRoutes.serviceDetail(item.id)),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
