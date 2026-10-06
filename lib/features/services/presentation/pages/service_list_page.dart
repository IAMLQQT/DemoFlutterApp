import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../bloc/service_list/service_list_bloc.dart';
import '../widgets/category_bar.dart';
import '../widgets/service_card.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<ServiceListBloc>()..add(const ServiceListRefreshed());
          // Keep the spinner until the bloc emits the refreshed result
          await bloc.stream.firstWhere((s) => s is! ServiceListLoading);
        },
        child: CustomScrollView(
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
              sliver: SliverToBoxAdapter(child: CategoryBar()),
            ),
            BlocBuilder<ServiceListBloc, ServiceListState>(
              builder: (context, state) => switch (state) {
                ServiceListLoading() => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ServiceListFailure(:final message) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Đã có lỗi: $message'),
                          TextButton(
                            onPressed: () =>
                                context.read<ServiceListBloc>().add(const ServiceListRefreshed()),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ServiceListLoaded(:final services) when services.isEmpty =>
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Chưa có dịch vụ nào')),
                  ),
                ServiceListLoaded(:final services) => SliverPadding(
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
                          onTap: () => context.push(AppRoutes.serviceDetail(item.id)),
                        );
                      },
                    ),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
