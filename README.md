<a href="https://pub.dev/packages/easy_audio_trimmer">
  <img alt="Pub Version" src="https://img.shields.io/pub/v/easy_audio_trimmer?style=flat-square">
</a>
<a href="https://github.com/mayurpitroda96/easy_audio_trimmer">
  <img alt="GitHub stars" src="https://img.shields.io/github/stars/mayurpitroda96/easy_audio_trimmer?style=flat-square">
</a>
<a href="https://github.com/mayurpitroda96/easy_audio_trimmer/blob/master/LICENSE">
  <img alt="GitHub license" src="https://img.shields.io/github/license/mayurpitroda96/easy_audio_trimmer?style=flat-square">
</a>

<h4 align="center">Welcome to Easy Audio Trimmer! This is a Flutter package that allows you to easily trim audio files within your Flutter app.</h4>

### Features

* Trim audio files within your Flutter app
* Specify the start and end times for the trimmed audio file
* Audio playback control.
* Retrieving and storing audio file.
* Trimmed audio files are saved on the device
* Easy to use with a simple function call
* Compatible with most audio file formats (mp3, wav, aac, etc.)
* Support for both iOS and Android platforms

## Example

The [example app](https://github.com/mayurpitroda96/easy_audio_trimmer/tree/master/example) running on android OnePlus 7:

<p align="center">
  <img src="https://raw.githubusercontent.com/mayurpitroda96/easy_audio_trimmer/master/screenshots/demo.gif" alt="Trimmer" width="300" height="600">
</p>

## Usage

Add the dependency `easy_audio_trimmer` to your **pubspec.yaml** file:

```yaml
dependencies:
  easy_audio_trimmer: ^1.0.0
```

### Android configuration

No additional configuration is needed for using on Android platform. You are good to go!

### iOS configuration

* Set the platform version in `ios/Podfile` to **10**.
  
  > Refer to the [FFmpeg Release](#ffmpeg-release) section.
   ```
   platform :ios, '10'
   ```

## FFmpeg Release

This package uses [LTS version](https://github.com/tanersener/ffmpeg-kit#10-lts-releases) of the FFmpeg implementation.

<table>
<thead>
    <tr>
        <th align="center"></th>
        <th align="center">LTS Release</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td align="center">Android API Level</td>
        <td align="center">16</td>
    </tr>
    <tr>
        <td align="center">Android Camera Access</td>
        <td align="center">-</td>
    </tr>
    <tr>
        <td align="center">Android Architectures</td>
        <td align="center">arm-v7a<br>arm-v7a-neon<br>arm64-v8a<br>x86<br>x86-64</td>
    </tr>
    <tr>
        <td align="center">iOS Min SDK</td>
        <td align="center">10</td>
    </tr>
    <tr>
        <td align="center">iOS Architectures</td>
        <td align="center">armv7<br>arm64<br>i386<br>x86-64</td>
    </tr>
</tbody>
</table>

## Functionalities

### Loading input audio file

```dart
final Trimmer _trimmer = Trimmer();
await _trimmer.loadAudio(audioFile: widget.file);
```

### Saving trimmed audio

Returns a string to indicate whether the saving operation was successful.

```dart
_trimmer.saveTrimmedAudio(
      startValue: _startValue,
      endValue: _endValue,
      audioFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
      },
    );
```

### Audio playback state 

Returns the audio playback state. If **true** then the audio is playing, otherwise it is paused.

```dart
await _trimmer.audioPlaybackControl(
  startValue: _startValue,
  endValue: _endValue,
);
```

## Widgets

### Display the audio trimmer area

```dart
TrimViewer(
  trimmer: _trimmer,
  viewerHeight: 50.0,
  viewerWidth: MediaQuery.of(context).size.width,
  maxAudioLength: const Duration(seconds: 10),
  onChangeStart: (value) => _startValue = value,
  onChangeEnd: (value) => _endValue = value,
  allowAudioSelection: true,
  onChangePlaybackState: (value) =>
      setState(() => _isPlaying = value),
)
```

## Example

Before using this example directly in a Flutter app, don't forget to add the `easy_audio_trimmer` & `file_picker` packages to your `pubspec.yaml` file.

You can try out this example by replacing the entire content of `main.dart` file of a newly created Flutter project.

```dart
import 'dart:io';
import 'package:example/trimmer_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: createMaterialColor(const Color(0xFF332FD0)),
        ),
        home: const FileSelectorWidget());
  }
}

class FileSelectorWidget extends StatefulWidget {
  const FileSelectorWidget({super.key});

  @override
  State<FileSelectorWidget> createState() => _FileSelectorWidgetState();
}

class _FileSelectorWidgetState extends State<FileSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Trimmer"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
                allowCompression: false,
              );
              if (result != null) {
                File file = File(result.files.single.path!);
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return AudioTrimmerView(file);
                  }),
                );
              }
            },
            child: const Text("Select File")),
      ),
    );
  }
}

class AudioTrimmerView extends StatefulWidget {
  final File file;

  const AudioTrimmerView(this.file, {Key? key}) : super(key: key);
  @override
  State<AudioTrimmerView> createState() => _AudioTrimmerViewState();
}

class _AudioTrimmerViewState extends State<AudioTrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadAudio();
  }

  void _loadAudio() async {
    setState(() {
      isLoading = true;
    });
    await _trimmer.loadAudio(audioFile: widget.file);
    setState(() {
      isLoading = false;
    });
  }

  _saveAudio() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedAudio(
      startValue: _startValue,
      endValue: _endValue,
      audioFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        debugPrint('OUTPUT PATH: $outputPath');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress) {
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Audio Trimmer"),
        ),
        body: isLoading
            ? const CircularProgressIndicator()
            : Center(
                child: Container(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Visibility(
                        visible: _progressVisibility,
                        child: LinearProgressIndicator(
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                      ElevatedButton(
                        onPressed:
                            _progressVisibility ? null : () => _saveAudio(),
                        child: const Text("SAVE"),
                      ),
                      AudioViewer(trimmer: _trimmer),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TrimViewer(
                            trimmer: _trimmer,
                            viewerHeight: 100,
                            viewerWidth: MediaQuery.of(context).size.width,
                            durationStyle: DurationStyle.FORMAT_MM_SS,
                            backgroundColor: Theme.of(context).primaryColor,
                            barColor: Colors.white,
                            durationTextStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            allowAudioSelection: true,
                            editorProperties: TrimEditorProperties(
                              circleSize: 10,
                              borderPaintColor: Colors.pink,
                              borderWidth: 4,
                              borderRadius: 5,
                              circlePaintColor: Colors.pink.shade800,
                            ),
                            areaProperties:
                                TrimAreaProperties.edgeBlur(blurEdges: true),
                            onChangeStart: (value) => _startValue = value,
                            onChangeEnd: (value) => _endValue = value,
                            onChangePlaybackState: (value) {
                              if (mounted) {
                                setState(() => _isPlaying = value);
                              }
                            },
                          ),
                        ),
                      ),
                      TextButton(
                        child: _isPlaying
                            ? Icon(
                                Icons.pause,
                                size: 80.0,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.play_arrow,
                                size: 80.0,
                                color: Theme.of(context).primaryColor,
                              ),
                        onPressed: () async {
                          bool playbackState =
                              await _trimmer.audioPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );
                          setState(() => _isPlaying = playbackState);
                        },
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
```

## Troubleshooting

While running on the Android platform if it gives an error that the `minSdkVersion` needs to be `24`, or on iOS platform that the Podfile platform version should be `11`, first go to `pubspec.lock` file and see if the version of `ffmpeg_kit_flutter` has `-LTS` suffix. This should fix all issues for iOS platform.

On Android, if you still face the same issue, try adding the following to the `<project_directory>/android/app/src/main/AndroidManifest.xml`:

```
<manifest xmlns:tools="http://schemas.android.com/tools" ....... >
    <uses-sdk tools:overrideLibrary="com.arthenica.ffmpegkit.flutter, com.arthenica.ffmpegkit" />
</manifest>
```


# Sponsored by

|  | |
|:-|:-|
| Agochar Tech LLP | https://agochar.com/ |


### Credit and Acknowledgment

"We would like to thank the contributors to the Video Trimmer repository for their invaluable assistance in creating this project. We used code from the Video Trimmer tool to implement the trimming and editing features in this project, and we are grateful for the opportunity to use it in our work. Thank you to the team behind Video Trimmer for their valuable contributions."


## License

Copyright (c) 2022 Mayur Pitroda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
