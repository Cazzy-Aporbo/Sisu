import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(AbsurdRoomApp());
}

class AbsurdRoomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultra-Surreal Absurd Room',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: AbsurdRoomScreen(),
    );
  }
}

class AbsurdRoomScreen extends StatefulWidget {
  @override
  _AbsurdRoomScreenState createState() => _AbsurdRoomScreenState();
}

class _AbsurdRoomScreenState extends State<AbsurdRoomScreen> {
  final Random random = Random();

  List<String> objects = ["spoon", "clock", "cup", "chair", "lamp", "door", "window"];
  List<String> actions = ["is staring at you", "walks sideways", "whispers nonsense", "spins slowly", "hides under the rug", "floats briefly"];
  List<String> envEvents = ["the floor laughs backward", "the ceiling sighs quietly", "the chair forgets itself", "the rug trembles in confusion"];
  List<String> memory = [];

  List<Color> pastelColors = [
    Color(0xFFFFE0F0), Color(0xFFFFE4E1), Color(0xFFFFF0F5), Color(0xFFE0FFFF),
    Color(0xFFE6E6FA), Color(0xFFF5F5DC), Color(0xFFF0FFF0), Color(0xFFFFFAF0),
    Color(0xFFFFF5EE), Color(0xFFF0FFFF)
  ];

  List<Widget> messages = [];

  @override
  void initState() {
    super.initState();

    // Start timed evolution
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        mutateRoom();
        addAbsurdEvents();
      });
    });

    // Add initial events
    addAbsurdEvents();
  }

  void addAbsurdEvents() {
    int count = random.nextInt(3) + 2; // 2-4 events
    for (int i = 0; i < count; i++) {
      messages.add(buildMessage(generateEvent()));
    }
  }

  String generateEvent() {
    String obj = objects[random.nextInt(objects.length)];
    String act = actions[random.nextInt(actions.length)];

    // Swap objects/actions mid-sentence randomly
    String line = random.nextBool() ? "$act $obj" : "$obj $act";

    // Sometimes include environmental surrealism
    if (random.nextDouble() < 0.3) {
      line += " while ${envEvents[random.nextInt(envEvents.length)]}";
    }

    // Sometimes ultra-backward text
    if (random.nextDouble() < 0.7) {
      line = ultraReverse(line);
    }

    memory.add(line);
    return line;
  }

  String ultraReverse(String str) {
    double r = random.nextDouble();
    if (r < 0.4) {
      return str.split('').reversed.join();
    } else if (r < 0.8) {
      List<String> words = str.split(' ');
      return words.reversed.join(' ');
    } else {
      List<String> words = str.split(' ');
      return words.reversed.join(' ').split('').reversed.join();
    }
  }

  void mutateRoom() {
    if (random.nextDouble() < 0.3) {
      objects.add("mysterious ${objects[random.nextInt(objects.length)]}");
    }
    if (random.nextDouble() < 0.2) {
      actions.add("does something inexplicable");
    }
    if (random.nextDouble() < 0.1) {
      envEvents.add("the wall hums softly");
    }
  }

  Widget buildMessage(String text) {
    Color color = pastelColors[random.nextInt(pastelColors.length)];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 18),
      ),
    );
  }

  void handleUserInput(String input) {
    if (input.isEmpty) return;

    String reply;
    double choice = random.nextDouble();
    if (choice < 0.3) {
      reply = random.nextBool()
          ? "${actions[random.nextInt(actions.length)]} $input"
          : "$input ${objects[random.nextInt(objects.length)]}";
    } else if (choice < 0.6) {
      reply =
          "Suddenly, ${objects[random.nextInt(objects.length)]} ${actions[random.nextInt(actions.length)]} in response to '$input'";
    } else {
      if (memory.isNotEmpty) {
        reply =
            "The room recalls: '${memory[random.nextInt(memory.length)]}' in response to '$input'";
      } else {
        reply = "The room stares silently at '$input'";
      }
    }

    // Ultra-backward
    if (random.nextDouble() < 0.8) reply = ultraReverse(reply);

    setState(() {
      messages.add(buildMessage(reply));
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Ultra-Surreal Absurd Room'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: messages,
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (value) {
                      handleUserInput(value);
                      controller.clear();
                    },
                    decoration: InputDecoration(
                      hintText: 'Say something to the room...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    handleUserInput(controller.text);
                    controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
