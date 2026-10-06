import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_action.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/get_service_detail.dart';
import '../bloc/service_detail/service_detail_bloc.dart';
import '../bloc/service_list/service_list_bloc.dart';
import '../widgets/booking_button.dart';
import '../widgets/detail_header.dart';
import '../widgets/service_html_content.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    // One bloc per opened page; closed automatically when the page is popped
    return BlocProvider(
      create: (context) => ServiceDetailBloc(context.read<GetServiceDetail>())
        ..add(ServiceDetailRequested(serviceId)),
      child: _ServiceDetailView(serviceId: serviceId),
    );
  }
}

class _ServiceDetailView extends StatefulWidget {
  const _ServiceDetailView({required this.serviceId});

  final String serviceId;

  @override
  State<_ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<_ServiceDetailView> {
  final ScrollController _scrollController = ScrollController();
  bool _showButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // always dispose controllers to avoid memory leaks
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final bool isAtBottom = position.pixels >= position.maxScrollExtent - 24;

    // null = no change (finger lifted / idle) -> keep current state
    final bool? shouldShow = switch (position.userScrollDirection) {
      _ when isAtBottom => true,
      ScrollDirection.reverse =>
        false, // content moving up = user scrolling down
      ScrollDirection.forward => true,
      ScrollDirection.idle => null,
    };

    if (shouldShow == null || shouldShow == _showButton) return;
    setState(() => _showButton = shouldShow);
  }

  void _onBook(BookingAction action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${action.label}: ${action.value}')));
  }

  @override
  Widget build(BuildContext context) {
    final ServiceListState listState = context.watch<ServiceListBloc>().state;
    final ServiceItem? summary =
        listState is ServiceListLoaded ? listState.findService(widget.serviceId) : null;
    final ServiceDetailState detailState = context.watch<ServiceDetailBloc>().state;
    final ServiceDetail? detail =
        detailState is ServiceDetailLoaded ? detailState.detail : null;

    // Header comes from the list right away; the article body loads separately
    final String? title = detail?.title ?? summary?.title;
    final String? bannerUrl = detail?.bannerUrl ?? summary?.bannerUrl;
    final BookingAction? action = detail?.bookingActions.firstOrNull; // first action, if any

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: title == null || bannerUrl == null
            ? Center(
                child: detailState is ServiceDetailFailure
                    ? Text('Đã có lỗi: ${detailState.message}')
                    : const CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: DetailHeader(bannerUrl: bannerUrl, title: title),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                        sliver: SliverToBoxAdapter(
                          child: switch (detailState) {
                            ServiceDetailLoading() => const Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            ServiceDetailFailure(:final message) => Text('Đã có lỗi: $message'),
                            ServiceDetailLoaded(:final detail) =>
                              ServiceHtmlContent(html: detail.contentHtml),
                          },
                        ),
                      ),
                    ],
                  ),
                  if (action != null)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(bottom: 16),
                        child: IgnorePointer(
                          ignoring:
                              !_showButton, // hidden button must not catch taps
                          child: AnimatedSlide(
                            offset: _showButton
                                ? Offset.zero
                                : const Offset(0, 2),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            child: BookingButton(
                              label: action.label,
                              onPressed: () => _onBook(action),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
