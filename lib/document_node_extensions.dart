import 'package:super_editor/super_editor.dart';
import 'package:super_test/document_node_serialization.dart';

extension DocumentNodeExtensions on DocumentNode {
  /// Converts the [DocumentNode] into a Map<String,dynamic>.
  Map<String, dynamic> toMap() {
    return DocumentNodeSerialization.nodeToMap(this);
  }

  /// This converts a map into a [DocumentNode]. Currently it only returns a TextNode.
  static DocumentNode? fromMap(Map<String, dynamic> nodeMap) {
    return DocumentNodeSerialization.nodeFromMap(nodeMap);
  }

  DocumentNode deepCopy() {
    switch (runtimeType) {
      case TextNode:
        TextNode thisNode = this as TextNode;
        return TextNode(
            id: id,
            text: AttributedText(
                text: thisNode.text.text,
                spans:
                    AttributedSpans(attributions: thisNode.text.spans.markers)),
            metadata: thisNode.copyMetadata());
      case ParagraphNode:
        ParagraphNode thisNode = this as ParagraphNode;
        return ParagraphNode(
            id: id,
            text: AttributedText(
                text: thisNode.text.text,
                spans:
                    AttributedSpans(attributions: thisNode.text.spans.markers)),
            metadata: thisNode.copyMetadata());
      case HorizontalRuleNode:
        return HorizontalRuleNode(id: id);
      case ImageNode:
        ImageNode thisNode = this as ImageNode;
        return ImageNode(
            id: id,
            imageUrl: thisNode.imageUrl,
            altText: thisNode.altText,
            metadata: thisNode.copyMetadata());
      case ListItemNode:
        ListItemNode thisNode = this as ListItemNode;
        return ListItemNode(
            id: id,
            itemType: thisNode.type,
            text: AttributedText(
                text: thisNode.text.text,
                spans:
                    AttributedSpans(attributions: thisNode.text.spans.markers)),
            metadata: thisNode.copyMetadata(),
            indent: thisNode.indent);
      default:
        throw ArgumentError.value(this,
            'Unacceptable Type passed as an argument. Only TextNode, ParagraphNode, HorizontalRuleNode, ImageNode and ListItemNode are accepted.');
    }
  }
}

extension DocumentNodeListExtensions on List<DocumentNode> {
  bool containsEquivalent(DocumentNode other) {
    for (DocumentNode e in this) {
      if (e.hasEquivalentContent(other)) return true;
    }
    return false;
  }
}
