import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/error_mapper.dart';
import '../../../../../core/error/failure.dart';
import '../../../domain/entities/service_detail.dart';
import '../../../domain/usecases/get_service_detail.dart';

part 'service_detail_event.dart';
part 'service_detail_state.dart';

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  ServiceDetailBloc(this._getServiceDetail) : super(const ServiceDetailLoading()) {
    on<ServiceDetailRequested>(_onRequested);
  }

  final GetServiceDetail _getServiceDetail;

  /// Also used by the "Thử lại" button: just request the same id again.
  Future<void> _onRequested(ServiceDetailRequested event, Emitter<ServiceDetailState> emit) async {
    emit(const ServiceDetailLoading());
    try {
      emit(ServiceDetailLoaded(await _getServiceDetail(event.serviceId)));
    } catch (error, stackTrace) {
      emit(ServiceDetailFailure(mapToFailure(error, stackTrace)));
    }
  }
}
