import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/domain/usecases/get_employee.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_provider.dart';

final employeeDetailsProvider = FutureProvider.family
    .autoDispose<Employee, String>((ref, id) async {
      final employee = await GetEmployee(ref.read(employeeRepositoryProvider))(
        id,
      );
      if (employee == null) {
        throw const UnexpectedFailure(
          message: 'This employee could not be found.',
        );
      }
      return employee;
    });
