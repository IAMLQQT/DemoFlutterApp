import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/service_category.dart';
import '../../../domain/entities/service_item.dart';
import '../../../domain/usecases/get_service_categories.dart';

part 'service_list_event.dart';
part 'service_list_state.dart';

class ServiceListBloc extends Bloc<ServiceListEvent, ServiceListState> {
  ServiceListBloc(this._getServiceCategories) : super(const ServiceListLoading()) {
    on<ServiceListStarted>(_onLoad);
    on<ServiceListRefreshed>(_onLoad);
    on<ServiceCategorySelected>(_onCategorySelected);
  }

  final GetServiceCategories _getServiceCategories;

  Future<void> _onLoad(ServiceListEvent event, Emitter<ServiceListState> emit) async {
    final ServiceListState previous = state;
    // Keep showing current data while refreshing; only a cold start shows the spinner
    if (previous is! ServiceListLoaded) emit(const ServiceListLoading());

    try {
      final categories = await _getServiceCategories();
      if (categories.isEmpty) {
        emit(const ServiceListFailure('Chưa có danh mục nào'));
        return;
      }
      // Keep the user's tab after a refresh if it still exists
      final String? keptId = previous is ServiceListLoaded &&
              categories.any((c) => c.id == previous.activeCategoryId)
          ? previous.activeCategoryId
          : null;
      emit(ServiceListLoaded(
        categories: categories,
        activeCategoryId: keptId ?? categories.first.id,
      ));
    } catch (e) {
      emit(ServiceListFailure(e.toString()));
    }
  }

  void _onCategorySelected(ServiceCategorySelected event, Emitter<ServiceListState> emit) {
    final ServiceListState current = state;
    if (current is! ServiceListLoaded) return;
    // Filtering in memory: no request, no loading state
    emit(current.copyWith(activeCategoryId: event.categoryId));
  }
}
