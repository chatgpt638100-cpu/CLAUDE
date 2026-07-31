import 'package:equatable/equatable.dart';

import 'text_element.dart';

/// The editable state of one invitation's canvas (Screen 4).
///
/// [elements] is also the paint order: the last entry sits in front of
/// the others. "Bring to Front" and "Send to Back" simply move an entry
/// within this list.
class EditorCanvas extends Equatable {
  final List<TextElement> elements;

  /// Which box currently shows its gold outline and handles, if any.
  final String? selectedElementId;

  const EditorCanvas({
    this.elements = const [],
    this.selectedElementId,
  });

  const EditorCanvas.empty()
      : elements = const [],
        selectedElementId = null;

  /// The selected element, or null when nothing is selected (or the
  /// selected id no longer exists).
  TextElement? get selectedElement {
    final id = selectedElementId;
    if (id == null) return null;
    for (final element in elements) {
      if (element.id == id) return element;
    }
    return null;
  }

  int indexOf(String id) {
    for (var i = 0; i < elements.length; i++) {
      if (elements[i].id == id) return i;
    }
    return -1;
  }

  /// [clearSelection] exists because `selectedElementId: null` cannot be
  /// told apart from "leave it alone" in a normal copyWith.
  EditorCanvas copyWith({
    List<TextElement>? elements,
    String? selectedElementId,
    bool clearSelection = false,
  }) {
    return EditorCanvas(
      elements: elements ?? this.elements,
      selectedElementId: clearSelection
          ? null
          : (selectedElementId ?? this.selectedElementId),
    );
  }

  @override
  List<Object?> get props => [elements, selectedElementId];
}
