import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _nameState();
}

class _nameState extends State<MyHomePage> {
  /*--------------Speeech To Text-------------------------- */
  bool isListed = false;
  var voiceLevel = 25.0;
  SpeechToText speechToText = SpeechToText();
  micCheck() async {
    bool mic = await speechToText.initialize();
    if (!mic) {
      micCheck();
    }
  }

  getVoice() {
    if (!isListed) {
      setState(() {
        isListed = true;
      });
      speechToText.listen(
        listenFor: Duration(minutes: 10),
        partialResults: false,
        onResult: (result) {
          getChatText(result.toString());
          setState(() {
            isListed = false;
          });
        },
        onSoundLevelChange: (level) {
          //=> -  max 10 min -10
          setState(() {
            voiceLevel = max(25.0, level * 5);
          });
        },
      );
    } else {
      setState(() {
        isListed = false;
        voiceLevel = 25.0;
      });
      speechToText.stop();
    }
  }

  /*--------------Speeech To Text-------------------------- */
  /*--------------Gemini Api--------------------------*/
  String keyapi = "AIzaSyB8_ckNQsPoR9rVBgW4vY6eLi3JnEUCO1k";
  getChatText(String text) {
    setState(() {
      step = 1;
    });
    Gemini gemini = Gemini.instance;
    gemini.text(text).then(
      (value) {
        setState(() {
          step = 2;
        });
        flutterTts.speak(value!.output.toString());
      },
    );
  }

  /*--------------Gemini Api--------------------------*/

  /*--------------Text to Speech--------------------------*/
  int step = 0;
  /*
  0 => frist page
  1 => loading page
  2 => fianl page
   */
  FlutterTts flutterTts = FlutterTts();
  var endHe = 70.0;
  initTTs() async {
    await flutterTts.awaitSpeakCompletion(true);
    flutterTts.setStartHandler(() {
      stratTimer();
    });
    flutterTts.setCompletionHandler(() {
      timer!.cancel();
      setState(() {
        endHe = 70.0;
        step = 0;
      });
    });
  }

  Timer? timer;
  stratTimer() {
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        endHe += 10;
        if (endHe > 100) {
          endHe = 70.0;
        }
      });
    });
  }

  canaclSpeech() {
    flutterTts.stop();
    setState(() {
      step = 0;
      isListed = false;
    });
  }
  /*--------------Text to Speech--------------------------*/

  @override
  void initState() {
    Gemini.init(apiKey: keyapi);
    micCheck();
    initTTs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          GestureDetector(
            onTap: () {
              getVoice();
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromARGB(255, 77, 77, 77),
              child: Icon(
                (step == 2)
                    ? Icons.square_rounded
                    : isListed
                        ? Icons.pause
                        : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          SizedBox(
            width: (step != 0) ? 90 : 50,
          ),
          Icon(
            (step != 0) ? Icons.mic_off : Icons.mic,
            color: (step != 0) ? Colors.grey : Colors.white,
          ),
          if (step == 0)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: voiceLevel == 25.0 ? 25.5 : voiceLevel * 1.1,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: voiceLevel == 25.0 ? 25.5 : voiceLevel * 1.2,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: voiceLevel == 25.0 ? 25.5 : voiceLevel * 1.5,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: voiceLevel == 25.0 ? 25.5 : voiceLevel * 1.1,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ],
            ),
          SizedBox(
            width: (step != 0) ? 100 : 60,
          ),
          GestureDetector(
            onTap: () {
              canaclSpeech();
            },
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Color.fromARGB(255, 255, 1, 1),
              child: Icon(
                Icons.close_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 150,
            ),
            if (step == 0)
              CircleAvatar(
                radius: 150,
                backgroundColor: Colors.white,
              ),
            if (step == 1)
              Lottie.asset("assets/loading.json",
                  height: 320, width: 320, fit: BoxFit.cover),
            if (step == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: endHe == 70 ? 70.0 : endHe * 1.1,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: endHe == 70 ? 70.0 : endHe * 1.2,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: endHe == 70 ? 70.0 : endHe * 1.5,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: endHe == 70 ? 70.0 : endHe * 1.1,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: (step == 2) ? 300 : 100,
            ),
            Text(
              (step == 1)
                  ? "Loading"
                  : isListed
                      ? "Listening"
                      : "Tap to start",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
