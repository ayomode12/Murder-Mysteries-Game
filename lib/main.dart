import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'node.dart';

List<Node> decisionMap =
    []; // Global list to store nodes parsed from the selected CSV
String selectedStoryline = ""; // Tracks the selected storyline
String correctKiller =
    ""; // Tracks the correct killer for the selected storyline

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCIcJcTaAxmGKGpMcF--LEdeNc5Hq8Hp2Y",
      authDomain: "murder-mysteries-game.firebaseapp.com",
      projectId: "murder-mysteries-game",
      storageBucket: "murder-mysteries-game.appspot.com",
      messagingSenderId: "1059749391732",
      appId: "1:1059749391732:web:0ebad1c62866c8ced99021",
      measurementId: "G-XBX5MNWGRP",
    ),
  );

  runApp(
    const MaterialApp(
      home: OpeningScreen(),
    ),
  );
}

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({Key? key}) : super(key: key);

  Future<void> loadCsv(String csvPath, BuildContext context, String storyline,
      String killer) async {
    decisionMap.clear(); // Clear any previously loaded decision map
    selectedStoryline = storyline; // Set the storyline
    correctKiller = killer; // Set the correct killer

    String fileData = await rootBundle.loadString(csvPath);

    List<String> rows = fileData.split("\n");
    for (int i = 1; i < rows.length; i++) {
      // Skip the header row
      String row = rows[i].trim();
      if (row.isEmpty) continue; // Skip empty rows

      try {
        // Use RegExp to split CSV rows while handling commas in quotes
        final pattern =
            RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)', multiLine: true);
        List<String> itemInRow = row.split(pattern);

        // Ensure the row has exactly 7 fields
        if (itemInRow.length < 7) {
          debugPrint("Invalid row $i: $row");
          continue;
        }

        int nodeId = int.parse(itemInRow[0].trim());
        String leftButtonText = itemInRow[1].trim();
        int leftNextNodeId =
            itemInRow[2].trim() == "-" ? -1 : int.parse(itemInRow[2].trim());
        String rightButtonText = itemInRow[3].trim();
        int rightNextNodeId =
            itemInRow[4].trim() == "-" ? -1 : int.parse(itemInRow[4].trim());
        String description =
            itemInRow[5].trim().replaceAll('"', ''); // Remove quotes
        String imageUrl = itemInRow[6].trim();

        // Create a Node object and add it to the decisionMap
        Node node = Node(nodeId, leftButtonText, leftNextNodeId,
            rightButtonText, rightNextNodeId, description, imageUrl);
        decisionMap.add(node);
      } catch (e) {
        debugPrint("Error parsing row $i: $e"); // Debug parsing errors
      }
    }

    // Navigate to the main game screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyFlutterApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                loadCsv("assets/csv_file.csv", context,
                    "The Politician's Demise", "The Ambitious Protegee");
              },
              child: const Text("The Politician's Demise"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loadCsv("assets/CSV_FILE2.csv", context,
                    "The Tragedy on the Balcony", "The Ex-boyfriend");
              },
              child: const Text("The Tragedy on the Balcony"),
            ),
          ],
        ),
      ),
    );
  }
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyFlutterState();
  }
}

class MyFlutterState extends State<MyFlutterApp> {
  late int iD; // Current node ID
  late String leftButtonText; // Text for the left button
  late int leftNextNodeId; // Next node ID for the left button
  late String rightButtonText; // Text for the right button
  late int rightNextNodeId; // Next node ID for the right button
  String description = ""; // Description text for the current node
  String imageUrl = ""; // Background image URL for the current node

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Initialize with the first node in the decisionMap
        if (decisionMap.isNotEmpty) {
          Node current = decisionMap.first;
          iD = current.iD;
          leftButtonText = current.leftButtonText;
          leftNextNodeId = current.leftNextNodeId;
          rightButtonText = current.rightButtonText;
          rightNextNodeId = current.rightNextNodeId;
          description = current.description;
          imageUrl = current.imageUrl;
        } else {
          // Fallback for empty decisionMap
          description = "No data available.";
          imageUrl = "assets/images/default_image.jpg"; // Fallback image
          leftButtonText = "N/A";
          rightButtonText = "N/A";
        }
      });
    });
  }

  void updateNode(int nextNodeId) {
    if (nextNodeId == -1) return; // Ignore invalid transitions
    setState(() {
      for (Node nextNode in decisionMap) {
        if (nextNode.iD == nextNodeId) {
          // Update the state to display the next node
          iD = nextNode.iD;
          leftButtonText = nextNode.leftButtonText;
          leftNextNodeId = nextNode.leftNextNodeId;
          rightButtonText = nextNode.rightButtonText;
          rightNextNodeId = nextNode.rightNextNodeId;
          description = nextNode.description;
          imageUrl = nextNode.imageUrl;
          debugPrint(
              "Navigated to node ID: $iD with image: $imageUrl"); // Debug navigation
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imageUrl.isNotEmpty
                ? imageUrl
                : 'assets/images/default_image.jpg'), // Fallback image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Description in a styled text box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.7), // Semi-transparent background
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                        color: Colors.white, width: 2), // White border
                  ),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      updateNode(leftNextNodeId);
                    },
                    child: Text(leftButtonText),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      updateNode(rightNextNodeId);
                    },
                    child: Text(rightButtonText),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GuessTheKillerScreen()),
                  );
                },
                child: const Text("Guess the Killer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuessTheKillerScreen extends StatelessWidget {
  const GuessTheKillerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final suspects =
        decisionMap.map((node) => node.leftButtonText).toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guess the Killer"),
      ),
      body: ListView.builder(
        itemCount: suspects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suspects[index]),
            onTap: () {
              if (suspects[index] == correctKiller) {
                // Correct guess
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("You Win!"),
                    content:
                        const Text("Congratulations! You guessed correctly."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to the CSV page
                        },
                        child: const Text("Play Again"),
                      ),
                    ],
                  ),
                );
              } else {
                // Incorrect guess
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("You Lose!"),
                    content: const Text("Wrong guess! Better luck next time."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.popUntil(
                              context,
                              (route) =>
                                  route.isFirst); // Go back to the main screen
                        },
                        child: const Text("Back to Main Screen"),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
