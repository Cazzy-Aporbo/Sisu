import 'dart:async';
import 'dart:math';

void main() {
  final rng = Random();

  List<int> numbers = List.generate(10, (_) => rng.nextInt(100));
  List<String> memory = [];

  String numberWhisper(int a, int b) {
    List<String> verbs = ["hums to", "glances at", "whispers to", "nudges"];
    String verb = verbs[rng.nextInt(verbs.length)];
    return "$a $verb $b";
  }

  String mutateNumber(int n) {
    double choice = rng.nextDouble();
    if (choice < 0.3) return "${-n}"; // invert
    else if (choice < 0.6) return "${n + rng.nextInt(50)}"; // mutate
    else if (choice < 0.8) return "${n ~/ 2}"; // halve
    else return "${n * 2}"; // double
  }

  Timer.periodic(Duration(seconds: 1), (timer) {
    // Each tick, numbers interact
    int a = numbers[rng.nextInt(numbers.length)];
    int b = numbers[rng.nextInt(numbers.length)];
    String interaction = numberWhisper(a, b);

    // Mutate numbers randomly
    for (int i = 0; i < numbers.length; i++) {
      numbers[i] = int.parse(mutateNumber(numbers[i]));
    }

    memory.add(interaction);

    // Echo past interactions sometimes
    if (rng.nextDouble() < 0.3 && memory.isNotEmpty) {
      interaction += " | echoes: ${memory[rng.nextInt(memory.length)]}";
    }

    print(interaction);
    print("Current numbers: ${numbers.join(', ')}\n");
  });
}