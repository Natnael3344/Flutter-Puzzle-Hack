
              ///*             ***********  Created By:- Natnael Tamirat ***********        *///

///* Packages used in this project *///

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  ///* Constants*///

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: const Interval(
      0.125,
      0.250,
      curve: Curves.ease,
    ),
  );
  ///  To display the stopwatch in the game. ///
  String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var hours = (secs ~/ 3600).toString().padLeft(2, '0');
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  late Stopwatch _stopwatch;
  bool isDisable = true;  /// To disable the button before we start the game. it will enable after we click the start button.
  late Timer _timer;
  int tiles=15;
  int move = 0;           /// To count the number of moves of the tiles.
  var list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]; /// The initial order of the puzzle before the game started.
  var check = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]; /// To check whether you win the game or not.
  int row = 0;      /// To check even or odd row
  int count = 0;    /// To count the number of inversions
  bool isLarge = false;  /// for Large devices
  bool isMedium = false; /// for Medium devices
  bool isSmall = true;   /// for Small devices



  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });///Important to update the stopwatch every second.
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ///      Change the values of isLarge, isMedium, isSmall values according to the  ///
    ///      size of the screens inorder to make the app responsive.                  ///

    if (MediaQuery.of(context).size.width < 1440 &&
        MediaQuery.of(context).size.width >= 1200) {
      isLarge = true;
      isMedium = false;
      isSmall = false;
    }
    if (MediaQuery.of(context).size.width < 1200 &&
        MediaQuery.of(context).size.width >= 576) {
      isMedium = true;
      isLarge = false;
      isSmall = false;
    }
    if (MediaQuery.of(context).size.width < 576) {
      isSmall = true;
      isLarge = false;
      isMedium = false;
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 48, 100),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment(1, isLarge ? 0.6 : 1),
                  image: const AssetImage("images/simple.png"),
                  scale: isSmall ? 5.5
                      : isMedium ? 2.5 : 2, /// for Small devices the background image's scale will be 5.5 for Medium devices 2.5 and for Large devices 2.
                  fit: BoxFit.scaleDown)),


          ///          This is the main part for the UI of the app. For Large devices we have three main sections          ///
          ///          the Header (the logo), the start(the start button), and the board(the puzzle). so we arrange        ///
          ///          the start and the board in a row then in column with the header. For Medium and Small devices we    ///
          ///          arrange the header, start and board all in column.                                                  ///

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              header(),
              Padding(
                padding: EdgeInsets.only(top: isSmall ? 0 : 60),
                child: isMedium || isSmall ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 20),
                      child: containerText2(35),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          containerText3(22),
                          buildTimer(35),
                        ],
                      ),
                    ),
                    isSmall
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Simple",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              color:
                              Color.fromARGB(255, 2, 125, 253),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              "Dashatar",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                    board(20),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 50),
                      child: shuffleButton(),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    start(),
                    Column(
                      children: [
                        buildTimer(35),
                        board(30),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.27,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


///   A method to display the stopwatch   ///

  Row buildTimer(double font) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatTime(_stopwatch.elapsedMilliseconds),
          style: TextStyle(
              color: Colors.white, fontSize: font, fontWeight: FontWeight.bold),
        ),
        const Icon(
          Icons.timer_outlined,
          color: Colors.white,
          size: 35,
        )
      ],
    );
  }

/// A method for the header section  ///

  ListTile header() {
    return ListTile(
      leading: isLarge || isMedium
          ? Image.asset(
        "images/flutter.png",
        scale: isMedium ? 3.5 : 3,
        color: Colors.white,
      )
          : const SizedBox.shrink(),
      contentPadding: const EdgeInsets.only(top: 23, left: 50, right: 5),
      horizontalTitleGap: 0,
      trailing: SizedBox(
        width: 350,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isSmall
                ? Center(
              child: Image.asset(
                "images/flutter.png",
                scale: 4,
                color: Colors.white,
              ),
            )
                : const SizedBox.shrink(),
            isLarge || isMedium
                ? const Text(
              "Simple",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Color.fromARGB(255, 2, 125, 253)),
            )
                : const SizedBox.shrink(),
            isLarge || isMedium
                ? const Text(
              "Dashatar",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            )
                : const SizedBox.shrink(),
            Icon(
              Icons.volume_up_rounded,
              size: isSmall ? 25 : 32,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

///  A method for Start section  ///

  SizedBox start() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.27,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLarge ? containerText1() : const SizedBox.shrink(),
          containerText2(55),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            child: containerText3(22),
          ),
          isLarge ? shuffleButton() : const SizedBox.shrink()
        ],
      ),
    );
  }


  ///   A button to shuffle the List and also to start the game.  ///
  SizedBox shuffleButton() {
    return SizedBox(
      width: 150,
      child: MaterialButton(
        onPressed: () {
          row=0;
          count=0;
          setState(() {
            var oneSec = const Duration(seconds: 1);
            var stop = const Duration(seconds: 1);

            ///   when the button is clicked it will starts shuffling for 3 seconds then the will timer stop when it reaches 3 seconds  ///
            ///   and the stopwatch will start also isDisable will change to false to enable the button.                                ///
            if(_stopwatch.isRunning){
              _stopwatch.reset();
              _stopwatch.stop();
            }

            list.shuffle();
            Timer.periodic(oneSec, (Timer timer) {
              stop = stop + const Duration(seconds: 1);
              shuffled();     /// it shuffles in the way we can solve the puzzle.
              if (stop == const Duration(seconds: 4)) {
                timer.cancel();
              }
              Future.delayed(const Duration(seconds: 4), () {

                _stopwatch.start();
                isDisable = false;
                print(row);
                print(count);
                print(list);
              });
            });
            move = 0;
          });

        },
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textColor: Colors.white,
        color: const Color.fromARGB(255, 2, 125, 253),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            const Icon(Icons.refresh_rounded),
            isDisable?const Text(
              "Start",
              style: TextStyle(fontWeight: FontWeight.bold),
            ):const Text("Restart", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Text containerText3(double fontSize) {
    return Text(
      move.toString() + " Moves | $tiles Tiles",
      style: TextStyle(
          color: const Color.fromARGB(255, 117, 191, 255),
          fontSize: fontSize,
          fontWeight: FontWeight.w600),
    );
  }

  Text containerText2(double fontSize) {
    return Text(
      "Puzzle Challenge",
      style: TextStyle(
          color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }

  Container containerText1() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: const Text(
        "Simple",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
      ),
    );
  }


///   Board section    ///
  Widget board(double top) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: SizedBox(
        height: isSmall ? MediaQuery.of(context).size.width * 0.85 : 500,
        width: isSmall ? MediaQuery.of(context).size.width * 0.65 : 450,
        child: AlignedGridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 7,
          crossAxisSpacing: 7,
          itemBuilder: (BuildContext context, int index) {

      ///   Display image if the current index of the list is different from 0. if it is zero display empty space. ///
            return list[index] != 0? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                          "images/" + list[index].toString() + ".png"),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 4, 104, 215),
                ),
                height: isSmall? MediaQuery.of(context).size.width * 0.15:110,
                width: isSmall?MediaQuery.of(context).size.width * 0.0875 : 100,
                child: MaterialButton(


           ///  This part contains the logic to move the tiles around.  ///
                  onPressed: isDisable ? null : () {
                    if (index - 1 >= 0 &&
                        list[index - 1] == 0 &&
                        index % 4 != 0 ||
                        index + 1 < 16 &&
                            list[index + 1] == 0 &&
                            (index + 1) % 4 != 0 ||
                        (index - 4 >= 0 && list[index - 4] == 0) ||
                        (index + 4 < 16 && list[index + 4] == 0)) {
                      setState(() {
                        move++;
                        list[list.indexOf(0)] = list[index];
                        list[index] = 0;
                      });
                    }

            /// if the above condition is not satisfied the game is won and stop the stopwatch. ///
                    win();
                  },
                ))
                : const SizedBox.shrink();
          },
          itemCount: list.length,
        ),
      ),
    );
  }

  ///      Here, is the logic to check whether the puzzle is solvable or not                                       ///
  ///      the puzzle is solvable if the zero is on an even row counting from the                                  ///
  ///      bottom (second-last, fourth-last, for this case we define row=1) and number of inversions is odd,       ///
  ///      the zero is on an odd row counting from the bottom (last, third-last, for this case we define row=2)    ///
  ///      and number of inversions is even. For all other cases, the puzzle instance is not solvable so           ///
  ///      we keep shuffling randomly using list.shuffle() till we get solvable puzzle.

  void shuffled() {
    if (list.indexOf(0) <= 15 && list.indexOf(0) >= 12 ||
        list.indexOf(0) <= 7 && list.indexOf(0) >= 4) {
      row = 1;
    }
    if (list.indexOf(0) <= 11 && list.indexOf(0) >= 8 ||
        list.indexOf(0) <= 3 && list.indexOf(0) >= 0) {
      row = 2;
    }
    while (true) {
      for (int i = 0; i < list.length - 1; i++) {
        for (int j = i + 1; j < list.length; j++) {
          if (list[i] > list[j] && list[j] != 0) {
            count = count + 1;
          }
        }
      }
      if (row == 1 && count % 2 == 0 || row == 2 && count % 2 != 0) {
        break;
      }
      list.shuffle();
    }
  }

 ///  Function to check if the game is won. and also for a congratulation message.   ///
  void win() {
    if (const IterableEquality().equals(list, check)) {
      _stopwatch.stop();
      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return FutureBuilder(
                future: Future.delayed(const Duration(seconds: 8)),
                builder: (c, s) => s.connectionState == ConnectionState.done
                    ? AlertDialog(
                  scrollable: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  titlePadding: EdgeInsets.all(isSmall ? 0 : 70),
                  contentPadding: EdgeInsets.only(
                      left: isSmall ? 5 : 70,
                      right: isSmall ? 5 : 70,
                      bottom: 70,
                      top: 10),
                  title: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 0, 48, 100),
                    ),
                    width: 600,
                    height: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.values[4],
                            children: [
                              Image.asset(
                                "images/flutter.png",
                                color: Colors.white,
                                scale: 5,
                              ),
                              RichText(
                                text: const TextSpan(
                                    text: "Puzzle Challenge Completed\n",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 117, 191, 255),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "\nWell Done.\nCongrats!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 33,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ]),
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Score",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 117, 191, 255),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: buildTimer(28),
                                  ),
                                  Text("$move Moves",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizeTransition(
                              sizeFactor: _animation,
                              axis: Axis.vertical,
                              axisAlignment: -0.5,
                              child: Image.asset("images/blu.png")),
                        ),
                      ],
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Share Your Score!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                          "Share this puzzle to challenge your friends!"),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          MaterialButton(
                              onPressed: () {},
                              height: 60,
                              minWidth: isSmall ? 50 : 160,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 19, 185, 253))),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    child: Image.asset(
                                      "images/twitter_icon.png",
                                      scale: 3,
                                    ),
                                    radius: 15,
                                    backgroundColor: const Color.fromARGB(
                                        255, 19, 185, 253),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const Text(
                                    "Twitter  ",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 19, 185, 253),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                ],
                              )),
                          SizedBox(
                            width: isSmall ? 10 : 30,
                          ),
                          MaterialButton(
                              onPressed: () {},
                              height: 60,
                              minWidth: isSmall ? 50 : 160,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                      color: Color.fromARGB(
                                          255, 4, 104, 215))),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: Image.asset(
                                      "images/facebook_icon.png",
                                      scale: 3,
                                    ),
                                    radius: 15,
                                    backgroundColor: const Color.fromARGB(
                                        255, 4, 104, 215),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const Text(
                                    "Facebook",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 4, 104, 215),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                ],
                              ))
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _stopwatch.reset();
                            isDisable = true;
                            move = 0;
                          });
                          Navigator.pop(context);
                          print("after win");
                          print(list);
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 48, 100),
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                )
                    : Lottie.asset("images/balloon.json"));
          });
    }
  }
}


