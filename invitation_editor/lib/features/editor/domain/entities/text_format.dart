/// Horizontal alignment of the words inside a text box (Screen 4 —
/// "Alignment — left/center/right, shown as labeled buttons").
///
/// A domain enum rather than Flutter's `TextAlign`, so the domain layer
/// stays free of Flutter types.
enum TextAlignmentOption { left, centre, right }

/// How much of a drop shadow sits behind the text.
///
/// Modelled as named steps instead of raw blur/offset/colour numbers:
/// three labeled choices are something this audience can judge at a
/// glance, where four numeric sliders would not be.
enum TextShadowStyle { none, soft, strong }
