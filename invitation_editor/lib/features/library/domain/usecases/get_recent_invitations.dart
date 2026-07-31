import '../entities/invitation_project.dart';

/// The few most recently edited invitations, shown as a "Recent" strip
/// above the full grid so the thing someone was last working on is one
/// tap away.
///
/// Pure and synchronous — it narrows a list that has already been loaded.
class GetRecentInvitations {
  const GetRecentInvitations();

  /// How many to surface. Small on purpose: a "recent" list long enough
  /// to need scrolling is just a second copy of the grid.
  static const int maxCount = 4;

  List<InvitationProject> call(List<InvitationProject> invitations) {
    final sorted = [...invitations]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(maxCount).toList();
  }
}
