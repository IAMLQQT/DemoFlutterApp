import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_action.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/service_item.dart';
import '../providers/service_providers.dart';
import '../widgets/booking_button.dart';
import '../widgets/detail_header.dart';
import '../widgets/service_html_content.dart';

class ServiceDetailPage extends ConsumerStatefulWidget {
  const ServiceDetailPage({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends ConsumerState<ServiceDetailPage> {
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
    final ServiceItem? summary = ref.watch(
      serviceSummaryProvider(widget.serviceId),
    );
    final AsyncValue<ServiceDetail> detailAsync = ref.watch(
      serviceDetailProvider(widget.serviceId),
    );
    final ServiceDetail? detail = detailAsync.value;

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
                child: detailAsync.hasError
                    ? Text('Đã có lỗi: ${detailAsync.error}')
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
                          child: detailAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, _) => Text('Đã có lỗi: $error'),
                            data: (d) =>
                                ServiceHtmlContent(html: d.contentHtml),
                          ),
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
