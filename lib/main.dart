import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  late Future<void> isInitialized;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    var videoUrl =
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    isInitialized = _controller.initialize();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: FutureBuilder(
        future: isInitialized,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error Loading: ${snapshot.error.toString()}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            print(_controller.value.aspectRatio);
            return Column(
              children: [
                AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(_controller),
                        Align(
                          alignment: Alignment.center,
                          child: AnimatedOpacity(
                            duration: Duration(seconds: 1),
                            opacity: isVisible ? 1.0 : 0.0,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.7)),
                              child: InkWell(
                                onTap: () {
                                  if (_controller.value.isPlaying) {
                                    _controller.pause();
                                    isVisible = true;
                                  } else {
                                    _controller.play();
                                    isVisible = false;
                                  }
                                },
                                child: _controller.value.isPlaying
                                    ? Icon(Icons.pause)
                                    : Icon(Icons.play_arrow),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 100,
                            height: double.infinity,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onDoubleTap: () {
                              print("double tap");
                              if (_controller.value.position -
                                      Duration(seconds: 10) >
                                  Duration.zero) {
                                var prevDuration = _controller.value.position -
                                    Duration(seconds: 10);
                                _controller.seekTo(prevDuration);
                              }
                            },
                            child: Container(
                              width: 100,
                              height: double.infinity,
                            ),
                          ),
                        )
                      ],
                    )),
                Slider(
                    min: 0.0,
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey,
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    value: _controller.value.position.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                    })
              ],
            );
          }

          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        },
        child: _controller.value.isPlaying
            ? Icon(Icons.pause)
            : Icon(Icons.play_arrow),
      ),
    );
  }
}
