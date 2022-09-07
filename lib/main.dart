import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_test/document_node_extensions.dart';

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
  //List<DocumentNode> localNodeList = [];
  // This list is for comparison purposes as it is not currently possible to do a deep copy of DocumentNodes.
  // Hence whenever a node is updated, the change is reflected immediately on the local node list making comparison
  // impossible. Hence we have created a list of nodes converted to strings which don't reflect changes and hence
  // can be compared to nodes in the remote list.
  List<MapEntry<String,String>> localNodeStringList = [];

  DocumentEditor? docEditor;


  @override
  void initState() {
    // This manually checks for node insertions, updates and deletions
    myDoc.addListener(() {
      print(checkForChanges());
      print(checkForChanges());
    });
  }

  NodeChange checkForChanges() {
    int nonMatchingNodeIndex = -1;
    int localNodesPassed = 0;
    for (int i =0;i<localNodeStringList.length;i++) {

      // If the local node string list is longer than the remote list, remove any leftover nodes.
      if (i >= myDoc.nodes.length) {
        localNodeStringList.removeRange(localNodesPassed,localNodeStringList.length);
        print('deleted ${localNodeStringList.length - localNodesPassed + 1} nodes on the end of the local node list');
        return NodeChange.delete;
      }

      // First check if the node IDs are the same
      if (localNodeStringList[i].key == myDoc.nodes[i].id) {
        // If the IDs are the same, check if the content is equivalent
        if (localNodeStringList[i].value != myDoc.nodes[i].toString()) {

          // If the content is not equivalent, trigger update change
          print('Update change triggered');
          localNodeStringList[i] = MapEntry(myDoc.nodes[i].id, myDoc.nodes[i].toString());
          return NodeChange.update;
        } else {
          //print('no changes detected');
        }
      } else {
        //print('ids dont match');
        nonMatchingNodeIndex = i;
        bool matchFound = false;
        // If the IDs are not the same, go down the list
        var count = nonMatchingNodeIndex;
        while (i + 1 <localNodeStringList.length) {
          if (localNodeStringList[count].key == myDoc.nodes[i].id) {
            // If a matching id is found later in the list, trigger delete change for missing node
            print('deleted node at index: $nonMatchingNodeIndex');
            localNodeStringList.removeAt(nonMatchingNodeIndex);
            return NodeChange.delete;
          }
          count++;
        }
        if (matchFound == false) {
          // If no matching id is found later in the list, trigger insert change
          print('inserted node at index $nonMatchingNodeIndex');
          localNodeStringList.insert(nonMatchingNodeIndex, MapEntry(myDoc.nodes[nonMatchingNodeIndex].id, myDoc.nodes[nonMatchingNodeIndex].toString()));
          return NodeChange.insert;
        }
      }
      localNodesPassed++;
    }

    // If you have gone through every node on the local list and there are still remote nodes
    // waiting to be checked. Those nodes should be appended to the local list.
    if (localNodesPassed < myDoc.nodes.length) {
      print('inserted ${myDoc.nodes.length - localNodesPassed} nodes on the end of the local node list');
      localNodeStringList.addAll(myDoc.nodes.sublist(localNodesPassed).map((e) => MapEntry(e.id, e.toString())));
      return NodeChange.insert;
    }
    return NodeChange.none;
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
          myDoc.insertNodeAfter(existingNode: myDoc.nodes.last, newNode: ParagraphNode(
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

enum NodeChange {
  insert,
  delete,
  update,
  none
}
