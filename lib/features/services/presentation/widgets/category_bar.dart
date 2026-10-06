import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/service_list/service_list_bloc.dart';
import 'category_item.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BlocBuilder<ServiceListBloc, ServiceListState>(
        builder: (context, state) => switch (state) {
          ServiceListLoading() => const Center(child: CircularProgressIndicator()),
          ServiceListFailure() => const Center(child: Text('Không tải được danh mục')),
          ServiceListLoaded(:final categories, :final activeCategoryId) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryItem(
                  category: category,
                  isSelected: category.id == activeCategoryId,
                  onTap: () => context
                      .read<ServiceListBloc>()
                      .add(ServiceCategorySelected(category.id)),
                );
              },
            ),
        },
      ),
    );
  }
}
