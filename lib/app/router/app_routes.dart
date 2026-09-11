/// Centralized route path definitions.
///
/// Every location string lives here so refactors and deep links stay safe.
abstract final class RoutePaths {
  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String accountDisabled = '/account-disabled';
  static const String authError = '/auth-error';
  static const String invitationAccept = '/invitations/accept';
  static const String dashboard = '/dashboard';
  static const String members = '/members';
  static const String membersCreate = '/members/create';
  static const String checkIn = '/check-in';
  static const String attendance = '/attendance';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlanCreate = '/subscriptions/plans/new';
  static const String payments = '/payments';
  static const String employees = '/admin/employees';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String branches = '/branches';
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Route for a member detail page, e.g. `/members/abc-123`.
  static String memberDetail(String id) => '/members/$id';

  /// Route for the edit page of a member, e.g. `/members/abc-123/edit`.
  static String memberEdit(String id) => '/members/$id/edit';

  /// Route to create/renew a subscription for a member,
  /// e.g. `/members/abc-123/subscriptions/new`.
  static String memberSubscriptionCreate(String id) =>
      '/members/$id/subscriptions/new';

  static const String employeeInvite = '/admin/employees/invite';

  static String employeeDetail(String id) => '/admin/employees/$id';

  static String employeeEdit(String id) => '/admin/employees/$id/edit';
}
