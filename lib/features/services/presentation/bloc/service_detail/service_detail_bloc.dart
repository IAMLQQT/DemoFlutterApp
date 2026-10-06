import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/service_detail.dart';
import '../../../domain/usecases/get_service_detail.dart';

part 'service_detail_event.dart';
part 'service_detail_state.dart';

class ServiceDetailBloc extends Bloc<ServiceDetailEvent, ServiceDetailState> {
  ServiceDetailBloc(this._getServiceDetail) : super(const ServiceDetailLoading()) {
    on<ServiceDetailRequested>(_onRequested);
  }

  final GetServiceDetail _getServiceDetail;

  Future<void> _onRequested(ServiceDetailRequested event, Emitter<ServiceDetailState> emit) async {
    emit(const ServiceDetailLoading());
    try {
      emit(ServiceDetailLoaded(await _getServiceDetail(event.serviceId)));
    } catch (e) {
      emit(ServiceDetailFailure(e.toString()));
    }
  }
}
