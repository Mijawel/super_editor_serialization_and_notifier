import 'package:super_editor/super_editor.dart';
import 'package:super_test/document_node_extensions.dart';

class NodeChanges {
  static List<NodeChange> checkForChanges(
      List<DocumentNode> localNodes, List<DocumentNode> remoteNodes) {
    List<NodeChange> nodeChanges = [];

    // Check each entry in local list to see if it appears in remote list
    // remove anything not in remote
    List<DocumentNode> nodesToRemove = [];
    for (var node in localNodes) {
      if (!remoteNodes.map((e) => e.id).contains(node.id)) {
        nodesToRemove.add(node);
      }
    }
    for (var node in nodesToRemove) {
      localNodes.remove(node);
      nodeChanges.add(NodeChange(type: NodeChangeType.delete, node: node));
    }

    // Check each entry in remote list to see if it appears in local list
    // add anything not in local
    for (int i = 0; i < remoteNodes.length; i++) {
      if (!localNodes.map((e) => e.id).contains(remoteNodes[i].id)) {
        var insertedNode = remoteNodes[i].deepCopy();
        if (i < localNodes.length) {
          localNodes.insert(i, insertedNode);
        } else {
          localNodes.add(insertedNode);
        }
        nodeChanges
            .add(NodeChange(type: NodeChangeType.insert, node: insertedNode));
      }
    }

    // Ensure the two lists have the same length and order.
    if (remoteNodes.length != localNodes.length) {
      throw StateError(
          'Local and remote DocumentNode lists are not of equal length.');
    }
    bool sameOrder = true;
    for (int i = 0; i < remoteNodes.length; i++) {
      if (remoteNodes[i].id != localNodes[i].id) {
        sameOrder = false;
      }
    }
    if (sameOrder == false) {
      throw StateError(
          'Local and remote DocumentNode lists are not in the same order.');
    }

    // Check each entry in local list (that appears in remote list) and update anything different
    for (int i = 0; i < remoteNodes.length; i++) {
      if (!remoteNodes[i].hasEquivalentContent(localNodes[i])) {
        var updatedNode = remoteNodes[i].deepCopy();
        localNodes[i] = updatedNode;
        nodeChanges
            .add(NodeChange(type: NodeChangeType.update, node: updatedNode));
      }
    }

    // Check lists are identical
    bool hasDifference = false;
    for (int i = 0; i < remoteNodes.length; i++) {
      if (!remoteNodes[i].hasEquivalentContent(localNodes[i]) ||
          remoteNodes[i].id != localNodes[i].id) {
        hasDifference = true;
      }
    }
    if (hasDifference == true) {
      throw StateError('Local and remote DocumentNode lists are not identical');
    }

    return nodeChanges;
  }
}

class NodeChange {
  NodeChangeType type;
  DocumentNode node;

  NodeChange({required this.type, required this.node});

  @override
  String toString() {
    return 'NodeChange - Type: $type Changed DocumentNode: ${node.toString()}';
  }
}

enum NodeChangeType { insert, delete, update }
