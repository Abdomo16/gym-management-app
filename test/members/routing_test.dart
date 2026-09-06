import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/app/router/app_routes.dart';

void main() {
  group('RoutePaths – members', () {
    test('members constant is /members', () {
      expect(RoutePaths.members, '/members');
    });

    test('membersCreate constant is /members/create', () {
      expect(RoutePaths.membersCreate, '/members/create');
    });

    test('memberDetail returns /members/<id>', () {
      expect(RoutePaths.memberDetail('abc-123'), '/members/abc-123');
    });

    test('memberDetail with a UUID-style id', () {
      const id = '550e8400-e29b-41d4-a716-446655440000';
      expect(RoutePaths.memberDetail(id), '/members/$id');
    });

    test('memberEdit returns /members/<id>/edit', () {
      expect(RoutePaths.memberEdit('abc-123'), '/members/abc-123/edit');
    });

    test('memberEdit with a UUID-style id', () {
      const id = '550e8400-e29b-41d4-a716-446655440000';
      expect(RoutePaths.memberEdit(id), '/members/$id/edit');
    });

    test('memberDetail and memberEdit share the same base path', () {
      const id = 'member-99';
      expect(RoutePaths.memberEdit(id), startsWith(RoutePaths.memberDetail(id)));
    });

    test('membersCreate is a static path (no :id segment)', () {
      // GoRouter resolves literal /members/create before the :id wildcard
      // because the static route is registered first. This test documents
      // that membersCreate is a fully static path (no colon syntax).
      expect(RoutePaths.membersCreate.contains(':'), isFalse);
      expect(RoutePaths.membersCreate, endsWith('/create'));
    });
  });

  group('RoutePaths – other constants sanity check', () {
    test('dashboard constant is /dashboard', () {
      expect(RoutePaths.dashboard, '/dashboard');
    });

    test('login constant is /login', () {
      expect(RoutePaths.login, '/login');
    });
  });
}
