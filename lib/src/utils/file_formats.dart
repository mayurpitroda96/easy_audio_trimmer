/// The audio file formats available for
/// generating the output trimmed audio.
///
/// The available formats are `mp4`, `mkv`,
/// `mov`, `flv`, `avi`, `wmv`& `gif`.
///
/// If you define a custom `FFmpeg` command
/// then this will be ignored.
///
class FileFormat {
  const FileFormat._(this.index);

  final int index;

  static const FileFormat mp3 = FileFormat._(0);
  static const FileFormat mkv = FileFormat._(1);
  static const FileFormat mov = FileFormat._(2);
  static const FileFormat flv = FileFormat._(3);
  static const FileFormat avi = FileFormat._(4);
  static const FileFormat wmv = FileFormat._(5);
  static const FileFormat gif = FileFormat._(6);

  static const List<FileFormat> values = <FileFormat>[mp3];

  @override
  String toString() {
    return const <int, String>{
      0: '.mp3',
    }[index]!;
  }
}
