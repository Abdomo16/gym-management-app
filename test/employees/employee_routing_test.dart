import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/router/route_guards.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

void main() {
  test('employee administration is manager-or-owner only', () {
    final requirement = routeRequirementFor(RoutePaths.employees);

    expect(requirement, RouteRequirement.managerOrOwner);
    expect(requirement!.allows(UserRole.owner), isTrue);
    expect(requirement.allows(UserRole.manager), isTrue);
    expect(requirement.allows(UserRole.receptionist), isFalse);
  });

  test('employee detail and edit paths remain distinct', () {
    final detail = RoutePaths.employeeDetail('employee-1');
    final edit = RoutePaths.employeeEdit('employee-1');

    expect(detail, isNot(edit));
    expect(detail, '/admin/employees/employee-1');
    expect(edit, '/admin/employees/employee-1/edit');
  });
}
