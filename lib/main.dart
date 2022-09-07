import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

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
  List<String> nodeStringList = [];

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
    print('myDoc nodes list length: ${myDoc.nodes.length}');
    print('currentNodeList list length: ${nodeStringList.length}');
    for (int i =0;i<nodeStringList.length;i++) {

      if (i > myDoc.nodes.length) {
        nodeStringList.removeRange(localNodesPassed,nodeStringList.length);
        break;
      }

      // First check if the node IDs are the same
      if (nodeStringList[i].id == myDoc.nodes[i].id) {
        print('ids match');
        print('local node: ${nodeStringList[i]}');
        print('remote node: ${myDoc.nodes[i].toString()}');
        // If the IDs are the same, check if the content is equivalent
        if (nodeStringList[i] != myDoc.nodes[i].toString()) {
          if (myDoc.nodes[i] is ParagraphNode) {
            var thisNode = myDoc.nodes[i] as ParagraphNode;
            var thisText = thisNode.text;
            var spans = thisText.spans;
            var markers = spans.markers;
            for (var marker in markers) {
              var attr = marker.attribution as NamedAttribution;
              var asdas = marker.markerType;
            }
          }
          // If the content is not equivalent, trigger update change
          print('Update change triggered');
          nodeStringList[i] = myDoc.nodes[i].toString();
          return NodeChange.update;
        } else {
          print('no changes detected');
        }
      } else {
        print('ids dont match');
        nonMatchingNodeIndex = i;
        bool matchFound = false;
        // If the IDs are not the same, go down the list
        var count = nonMatchingNodeIndex;
        while (i + 1 <localNodeList.length) {
          if (localNodeList[count].id == myDoc.nodes[i].id) {
            // If a matching id is found later in the list, trigger delete change for missing node
            print('deleted node at index: $nonMatchingNodeIndex');
            localNodeList.removeAt(nonMatchingNodeIndex);
            return NodeChange.delete;
          }
          count++;
        }
        if (matchFound == false) {
          // If no matching id is found later in the list, trigger insert change
          print('inserted node at index $nonMatchingNodeIndex');
          localNodeList.insert(nonMatchingNodeIndex, myDoc.nodes[nonMatchingNodeIndex]);
          return NodeChange.insert;
        }
      }
      localNodesPassed++;
    }

    // If you have gone through every node on the local list and there are still remote nodes
    // waiting to be checked. Those nodes should be appended to the local list.
    if (localNodesPassed < myDoc.nodes.length) {
      print('adding ${myDoc.nodes.length - localNodesPassed} to the local node list');
      localNodeList.addAll(myDoc.nodes.sublist(localNodesPassed));
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
