/// Hands out identifiers for newly created canvas elements.
///
/// A timestamp alone is not enough: duplicating a box twice in the same
/// millisecond would collide, so a per-instance counter is mixed in. Ids
/// stay unique across a session and remain sortable by creation time,
/// which will matter once invitations are written to storage.
class IdGenerator {
  int _counter = 0;

  String next(String prefix) {
    _counter++;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_counter';
  }
}
