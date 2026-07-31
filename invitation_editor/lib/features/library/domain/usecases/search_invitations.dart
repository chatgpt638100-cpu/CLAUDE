import '../entities/invitation_project.dart';

/// Filters the library by title (Screen 1 — search).
///
/// Pure and synchronous: it works on the list already in memory rather
/// than going back to storage on every keystroke, which keeps typing
/// responsive and avoids a flood of disk reads.
class SearchInvitations {
  const SearchInvitations();

  List<InvitationProject> call(
    List<InvitationProject> invitations,
    String query,
  ) {
    if (query.trim().isEmpty) return invitations;
    return [
      for (final invitation in invitations)
        if (invitation.matches(query)) invitation,
    ];
  }
}
