import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/invitation_project.dart';
import '../../domain/usecases/delete_invitation.dart';
import '../../domain/usecases/duplicate_invitation.dart';
import '../../domain/usecases/get_all_invitations.dart';
import '../../domain/usecases/get_recent_invitations.dart';
import '../../domain/usecases/rename_invitation.dart';
import '../../domain/usecases/search_invitations.dart';

/// The saved invitations behind the Library grid (Screen 1).
///
/// An [AsyncNotifier] because the first read hits the disk: the screen
/// gets a real loading state and a real error state instead of flashing an
/// empty grid and pretending nothing is stored.
class LibraryNotifier extends AsyncNotifier<List<InvitationProject>> {
  @override
  Future<List<InvitationProject>> build() => sl<GetAllInvitations>()();

  /// Re-reads from storage. Called after returning from the Editor, where
  /// auto-save may have changed titles, thumbnails and edit times.
  Future<void> reload() async {
    state = await AsyncValue.guard(() => sl<GetAllInvitations>()());
  }

  Future<void> rename(String id, String title) async {
    await sl<RenameInvitation>()(id, title: title);
    await reload();
  }

  Future<void> duplicate(String id) async {
    await sl<DuplicateInvitation>()(
      id,
      newId: sl<IdGenerator>().next('invitation'),
    );
    await reload();
  }

  Future<void> delete(String id) async {
    await sl<DeleteInvitation>()(id);
    await reload();
  }
}

final libraryProvider =
    AsyncNotifierProvider<LibraryNotifier, List<InvitationProject>>(
  LibraryNotifier.new,
);

/// What the user has typed into the Library search field.
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// The grid's contents: everything saved, narrowed by the search query.
///
/// A derived provider rather than filtering inside the widget, so the
/// search box and the grid cannot disagree, and typing does not trigger a
/// re-read from disk.
final filteredInvitationsProvider = Provider<List<InvitationProject>>((ref) {
  final all = ref.watch(libraryProvider).valueOrNull ?? const [];
  final query = ref.watch(librarySearchQueryProvider);
  return sl<SearchInvitations>()(all, query);
});

/// The handful of most recently edited invitations, ignoring any search
/// term — "Recent" means recent, not "recent among the matches".
final recentInvitationsProvider = Provider<List<InvitationProject>>((ref) {
  final all = ref.watch(libraryProvider).valueOrNull ?? const [];
  return sl<GetRecentInvitations>()(all);
});
