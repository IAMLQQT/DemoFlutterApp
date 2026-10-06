/// Trimmed copies of real responses from the dev API (shape kept, content shortened).
Map<String, dynamic> screenItemJson(String id, {bool hot = false, String slider = 'slider.png'}) => {
      'img': 'https://cdn.test/$id.png?w=524&format=webp',
      'title': 'Title $id',
      'href': 'https://mobile.test/news/$id',
      'is_hot_news': hot,
      'action': null,
      'id': id,
      'slide': false,
      'is_show_button': false,
      'slider_image': slider,
      'created_at': '17/06/2026 09:47:47',
      'share_link': 'https://mobile.test/news/$id',
      'slug': id,
    };

Map<String, dynamic> screenCategoryJson(String id, String name, int sort, List<String> itemIds) => {
      'sort': sort,
      'name': name,
      'image': 'https://cdn.test/$id.png',
      'id': id,
      'news': [
        {'type': 1, 'items': <Object>[]},
        {'type': 2, 'items': [for (final i in itemIds) screenItemJson(i, hot: sort == 1)]},
      ],
    };

Map<String, dynamic> screenResponseJson() => {
      'status': 200,
      'code': 1,
      'message': 'success',
      'data': [
        screenCategoryJson('hot-id', 'Dịch vụ HOT', 1, ['a', 'b']),
        screenCategoryJson('skin-id', 'Điều trị da công nghệ cao', 2, ['c']),
        screenCategoryJson('care-id', 'Chăm sóc sau làm ', 6, <String>[]),
      ],
    };

Map<String, dynamic> detailJson(String id, {bool showButton = true, bool active = true}) => {
      'id': id,
      'slider_img': 'https://cdn.test/banner-$id.jpg',
      'is_show_button': showButton,
      'action': {
        'id': '1397',
        'active': active,
        'action_type': 'screens',
        'type': 'screens',
        'value': '/scheduler',
        'screen': null,
        'button_title': 'ĐẶT LỊCH NGAY',
      },
      'title': 'Detail $id',
      'content': '<!DOCTYPE html><html><head><title>x</title></head>'
          '<body><p>Noi dung $id</p></body></html>',
      'is_claimed': false,
      'share_link': 'https://mobile.test/news/$id',
    };

Map<String, dynamic> detailResponseJson(String id) =>
    {'status': 200, 'code': 1, 'message': 'success', 'data': detailJson(id)};

const Map<String, dynamic> notFoundResponseJson = {
  'status': 404,
  'code': -400,
  'message': 'Không tìm thấy dữ liệu.',
  'error_code': -400,
  'error_message': 'Không tìm thấy dữ liệu.',
  'data': null,
};
