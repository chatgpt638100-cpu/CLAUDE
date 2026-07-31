# Invitation Card Editor — Phase 1

Offline-first Flutter invitation card editor. Built in small phases per the
approved project architecture and UI/UX design spec.

## Phase 1 scope (this delivery)

- Project skeleton + folder structure (Clean Architecture, per architecture doc)
- `pubspec.yaml` with all dependencies from the spec
- Global theme: "Warm Ivory & Gold"
- Reusable widgets: PrimaryButton, SecondaryButton, AppCard, AppDialog, AppTopBar
- Empty placeholder screens for all 7 screens
- Navigation wired up with `go_router`
- **Only the Home (Library) screen has real UI** — static sample data, no storage

Explicitly NOT included yet: uploading, templates, editor, voice typing, smart
features, PDF export, database, or any business logic.

## Getting this running on your machine

This project was generated as source files only (no Flutter SDK available in
this environment to run `flutter create` or `flutter pub get`). To run it:

1. Copy this folder to a machine with the Flutter SDK installed.
2. Since platform folders (`android/`, `ios/`) were not generated here, run:
   ```
   flutter create .
   ```
   from inside this project folder — this fills in the `android/` and `ios/`
   folders around the existing `lib/` and `pubspec.yaml` without overwriting them.
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Folder structure

See `lib/` — it mirrors the architecture document exactly: `core/`,
`features/<feature>/{data,domain,presentation}`, `routes/`, `injection/`.
Empty folders contain a `.gitkeep` placeholder so the structure is preserved
before those layers have real files.
