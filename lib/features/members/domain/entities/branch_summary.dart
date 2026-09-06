/// Minimal read-only view of a branch used by the member forms.
///
/// Only branches belonging to the authenticated organization are ever
/// fetched; RLS enforces the tenant boundary server-side.
class BranchSummary {
  const BranchSummary({required this.id, required this.name});

  final String id;
  final String name;
}
