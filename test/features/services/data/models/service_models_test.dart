import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/features/services/data/models/service_category_model.dart';
import 'package:test_app/features/services/data/models/service_detail_model.dart';
import 'package:test_app/features/services/data/models/service_item_model.dart';

import '../../../../helpers/service_fixtures.dart';

void main() {
  group('ServiceCategoryModel', () {
    test('flattens items from every news group and maps to entity', () {
      final entity =
          ServiceCategoryModel.fromJson(screenCategoryJson('hot-id', 'Dịch vụ HOT', 1, ['a', 'b']))
              .toEntity();

      expect(entity.id, 'hot-id');
      expect(entity.iconUrl, 'https://cdn.test/hot-id.png');
      expect(entity.isHot, isTrue);
      expect(entity.services.map((s) => s.id), ['a', 'b']);
    });

    test('trims the name and is not hot without HOT in it', () {
      final model =
          ServiceCategoryModel.fromJson(screenCategoryJson('care-id', 'Chăm sóc sau làm ', 6, []));

      expect(model.name, 'Chăm sóc sau làm');
      expect(model.isHot, isFalse);
      expect(model.items, isEmpty);
    });
  });

  group('ServiceItemModel', () {
    test('maps img to thumbnail and slider_image to banner', () {
      final entity = ServiceItemModel.fromJson(screenItemJson('a', hot: true)).toEntity();

      expect(entity.thumbnailUrl, 'https://cdn.test/a.png?w=524&format=webp');
      expect(entity.bannerUrl, 'slider.png');
      expect(entity.isHot, isTrue);
    });

    test('falls back to img when slider_image is empty', () {
      final entity = ServiceItemModel.fromJson(screenItemJson('a', slider: '')).toEntity();

      expect(entity.bannerUrl, entity.thumbnailUrl);
    });
  });

  group('ServiceDetailModel', () {
    test('exposes the booking action when shown and active', () {
      final entity = ServiceDetailModel.fromJson(detailJson('x')).toEntity();

      expect(entity.title, 'Detail x');
      expect(entity.bannerUrl, 'https://cdn.test/banner-x.jpg');
      expect(entity.contentHtml, contains('Noi dung x'));
      expect(entity.bookingActions.single.label, 'ĐẶT LỊCH NGAY');
      expect(entity.bookingActions.single.value, '/scheduler');
    });

    test('hides the booking action when is_show_button is false', () {
      final entity = ServiceDetailModel.fromJson(detailJson('x', showButton: false)).toEntity();

      expect(entity.bookingActions, isEmpty);
    });

    test('hides the booking action when the action is inactive', () {
      final entity = ServiceDetailModel.fromJson(detailJson('x', active: false)).toEntity();

      expect(entity.bookingActions, isEmpty);
    });

    test('accepts a null action', () {
      final json = detailJson('x')..['action'] = null;

      expect(ServiceDetailModel.fromJson(json).toEntity().bookingActions, isEmpty);
    });
  });
}
