import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {

  late VideoPlayerController _controller;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/videos/introduction_video.mp4")
      ..initialize().then((_) {
        setState(() {_isInitialized = true;});
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0); // mute
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Video Background
            if (_isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            // Dark overlay for readability
            Container(
              color: Colors.black.withOpacity(0.5),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo_text.png",
                        height: 100,
                        width: 100,
                      ),
                      Text(
                        "SneakerX",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFAAF2C9),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80)
                      ),
                      border: Border.all(
                        color: Colors.black,
                        width: 10
                      )
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50, top: 50, bottom: 20),
                      child: Column(
                        children: [
                          Text(
                            "Start being immersed in sneaker world around you.",
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(height: 20,),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF262626),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                                )
                              ),
                              onPressed: () {},
                              child: Text(
                                "Sign in",
                                style: GoogleFonts.inter(
                                  color: Color(0xFFAAF2C9),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                child: Text(
                                  "Or Create Account >>>",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black
                                  ),
                                ),
                                onPressed: () {},
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}