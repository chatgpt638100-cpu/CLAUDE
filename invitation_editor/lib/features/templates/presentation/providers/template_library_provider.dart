import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection/service_locator.dart';
import '../../domain/entities/invitation_template.dart';
import '../../domain/entities/template_category.dart';
import '../../domain/usecases/delete_template.dart';
import '../../domain/usecases/get_templates.dart';
import '../../domain/usecases/rename_template.dart';

/// The saved templates behind the Template Library grid (Screen 3).
class TemplateLibraryNotifier
    extends AsyncNotifier<List<InvitationTemplate>> {
  @override
  Future<List<InvitationTemplate>> build() => sl<GetTemplates>()();

  Future<void> reload() async {
    state = await AsyncValue.guard(() => sl<GetTemplates>()());
  }

  Future<void> rename(String id, String name) async {
    await sl<RenameTemplate>()(id, name: name);
    await reload();
  }

  Future<void> delete(String id) async {
    await sl<DeleteTemplate>()(id);
    await reload();
  }
}

final templateLibraryProvider =
    AsyncNotifierProvider<TemplateLibraryNotifier, List<InvitationTemplate>>(
  TemplateLibraryNotifier.new,
);

/// Which category pill is active. Null means "All".
final selectedTemplateCategoryProvider =
    StateProvider<TemplateCategory?>((ref) => null);

/// The grid's contents: every template, narrowed by the active pill.
///
/// Filtering happens here rather than by re-querying, so switching tabs is
/// instant and does not touch the disk.
final visibleTemplatesProvider = Provider<List<InvitationTemplate>>((ref) {
  final all = ref.watch(templateLibraryProvider).valueOrNull ?? const [];
  final category = ref.watch(selectedTemplateCategoryProvider);
  if (category == null) return all;
  return [
    for (final template in all)
      if (template.category == category) template,
  ];
});
