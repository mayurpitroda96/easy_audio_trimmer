## 2.0.0

* **Migration & Modernization**:
  * Added support for the latest Flutter SDK versions (SDK `>= 3.0.0`).
  * Upgraded core audio engine to `audioplayers: ^6.7.0` for reliable modern playback and state observation.
  * Replaced `ffmpeg_kit_flutter` with `ffmpeg_kit_flutter_new: ^4.1.0` for modern compatibility.
  * Modernized example app's Android configurations to Gradle Kotlin DSL (`build.gradle.kts` and settings.gradle.kts).
  * Upgraded and fixed `file_picker` Android compilation error (`cannot find symbol: class FilePickerPlugin`) under modern Kotlin/Gradle environment.

* **Bug Fixes**:
  * Fixed a bug where `TrimViewer` completely disappeared (`const SizedBox()`) after initialization of trimmer. It now consistently renders `FixedTrimViewer`.
  * Resolved an issue where the center handle could still be dragged when `allowAudioSelection` was set to `false`.

* **Features**:
  * Fully integrated `StorageDir.externalStorageDirectory` support in the example app to save trimmed audio directly to accessible external storage.

## 1.0.1+4

* Update plugin versions

## 1.0.1+3

* Update plugin versions

## 1.0.1+2

* Added more description.

## 1.0.1+1

* Trimmer Demo Preview Added.

## 1.0.1

* README ADDED.

## 1.0.0

* Initial Open Source release.
