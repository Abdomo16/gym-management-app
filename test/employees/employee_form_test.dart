import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/features/employees/presentation/widgets/employee_form.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/presentation/providers/organization_branches_provider.dart';

void main() {
  Widget buildForm() {
    return ProviderScope(
      overrides: [
        organizationBranchesProvider.overrideWith(
          (ref) async => const [
            BranchSummary(id: 'branch-1', name: 'Main Branch'),
          ],
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: EmployeeForm(
            onSubmit:
                ({
                  required fullName,
                  required email,
                  required phone,
                  required role,
                  required branchId,
                }) {},
            submitLabel: 'Send invitation',
          ),
        ),
      ),
    );
  }

  testWidgets('invite form validates required fields', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send invitation'));
    await tester.pump();

    expect(find.text('Full name is required.'), findsOneWidget);
    expect(find.text('This field is required.'), findsOneWidget);
    expect(find.text('Select a branch.'), findsOneWidget);
  });

  testWidgets('invite form rejects invalid email', (tester) async {
    await tester.pumpWidget(buildForm());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sara Ali');
    await tester.enterText(fields.at(1), 'not-an-email');
    await tester.tap(find.text('Send invitation'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
