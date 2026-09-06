import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/app/router/app_routes.dart';

void main() {
  group('RoutePaths – subscriptions', () {
    test('memberSubscriptionCreate builds the member-scoped path', () {
      expect(
        RoutePaths.memberSubscriptionCreate('member-1'),
        '/members/member-1/subscriptions/new',
      );
    });

    test('memberSubscriptionCreate keeps the create route distinct', () {
      expect(
        RoutePaths.memberSubscriptionCreate('create'),
        isNot(RoutePaths.membersCreate),
      );
    });

    test('memberSubscriptionCreate is distinct from member detail', () {
      expect(
        RoutePaths.memberSubscriptionCreate('member-1'),
        isNot(RoutePaths.memberDetail('member-1')),
      );
      expect(
        RoutePaths.memberSubscriptionCreate('member-1'),
        isNot(RoutePaths.memberEdit('member-1')),
      );
    });

    test('existing members routes are unchanged', () {
      expect(RoutePaths.members, '/members');
      expect(RoutePaths.membersCreate, '/members/create');
      expect(RoutePaths.memberDetail('m1'), '/members/m1');
      expect(RoutePaths.memberEdit('m1'), '/members/m1/edit');
    });
  });
}
