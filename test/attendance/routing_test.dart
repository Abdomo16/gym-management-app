import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/app/router/app_routes.dart';

void main() {
  group('RoutePaths – attendance', () {
    test('check-in route is dedicated and stable', () {
      expect(RoutePaths.checkIn, '/check-in');
    });

    test('member detail check-in target preserves the member id', () {
      const memberId = 'member-1';
      final location =
          '${RoutePaths.checkIn}?memberId=${Uri.encodeComponent(memberId)}';

      expect(location, '/check-in?memberId=member-1');
    });
  });
}