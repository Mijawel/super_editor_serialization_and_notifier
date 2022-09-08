import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_test/node_changes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myDoc = MutableDocument(
    nodes: [
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(text: 'This is a header'),
        metadata: {
          'blockType': header1Attribution,
        },
      ),
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(text: 'This is the first paragraph'),
      ),
    ],
  );

  // This list is for comparison purposes.
  List<DocumentNode> localNodes = [];

  DocumentEditor? docEditor;

  @override
  void initState() {
    // This manually checks for node insertions, updates and deletions
    myDoc.addListener(() {
      var changes = NodeChanges.checkForChanges(localNodes, myDoc.nodes);
      for (var change in changes) {
        print(change);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    docEditor ??= DocumentEditor(document: myDoc);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SuperEditor(
        editor: docEditor!,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myDoc.insertNodeAfter(
              existingNode: myDoc.nodes.last,
              newNode: ParagraphNode(
                id: DocumentEditor.createNodeId(),
                text: AttributedText(text: 'This is the second paragraph'),
              ));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

