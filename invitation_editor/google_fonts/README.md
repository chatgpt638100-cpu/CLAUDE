# Bundled Google Fonts

The app runs fully offline and has no INTERNET permission, so
`google_fonts` is configured with runtime fetching disabled
(`AppFonts.configureOffline()` in `lib/main.dart`).

Font files must therefore be bundled here. Drop the `.ttf` files into
this folder using the package's naming convention:

    Lora-Regular.ttf
    Lora-Bold.ttf
    Lora-Italic.ttf
    Lora-BoldItalic.ttf

No code change is needed — `AppFonts.resolve()` picks them up
automatically. Families listed in `AppFonts.catalogue` that have no file
here fall back to the app's bundled serif instead of failing.

The catalogue currently expects: Playfair Display, Cormorant Garamond,
EB Garamond, Libre Baskerville, Lora, Marcellus, Great Vibes,
Dancing Script, Parisienne, Inter, Nunito Sans, Montserrat.
