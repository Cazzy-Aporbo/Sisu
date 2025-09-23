import 'dart:math';
import 'dart:async';

void main() {
  final Random rng = Random();
  List<String> words = ["spoon", "clock", "cup", "chair", "lamp", "door"];
  List<String> actions = ["dances sideways", "whispers secrets", "spins slowly", "melts quietly"];
  List<String> memory = [];

  Timer.periodic(Duration(seconds: 1), (timer) {
    String obj = words[rng.nextInt(words.length)];
    String act = actions[rng.nextInt(actions.length)];

    // Randomly swap objects and actions
    String line = rng.nextBool() ? "$act $obj" : "$obj $act";

    // Randomly reverse words or letters
    double chance = rng.nextDouble();
    if (chance < 0.3) {
      line = line.split('').reversed.join();
    } else if (chance < 0.6) {
      line = line.split(' ').reversed.join(' ');
    }

    memory.add(line);

    // Occasionally echo memory
    if (rng.nextDouble() < 0.2 && memory.isNotEmpty) {
      line += " | echoes: ${memory[rng.nextInt(memory.length)]}";
    }

    print(line);
  });
}