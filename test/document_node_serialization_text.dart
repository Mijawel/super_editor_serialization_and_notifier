import 'package:super_editor/super_editor.dart';
import 'package:super_test/document_node_extensions.dart';
import 'package:super_test/document_node_serialization.dart';
import 'package:test/test.dart';

void main() {
  test('TextNode should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();
    String testText = 'test_text';
    List<SpanMarker> markers = [];
    markers.add(const SpanMarker(
        attribution: NamedAttribution('header1'),
        offset: 1,
        markerType: SpanMarkerType.start));

    final originalNode = TextNode(
        id: nodeId,
        text: AttributedText(
            text: testText,
            spans: AttributedSpans(attributions: markers)),
        metadata: {'blockType': '[NamedAttribution]: paragraph'});

    var textNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(textNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(textNodeMap['id'], nodeId);
  });

  test('ParagraphNode should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();
    String testText = 'test_text';
    List<SpanMarker> markers = [];
    markers.add(const SpanMarker(
        attribution: NamedAttribution('header1'),
        offset: 1,
        markerType: SpanMarkerType.start));

    final originalNode = ParagraphNode(
        id: nodeId,
        text: AttributedText(
            text: testText,
            spans: AttributedSpans(attributions: markers)),
        metadata: {'blockType': '[NamedAttribution]: paragraph'});

    var paragraphNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(paragraphNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(paragraphNodeMap['id'], nodeId);
  });

  test('HorizontalRuleNode should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();

    final originalNode = HorizontalRuleNode(
        id: nodeId);

    var horizontalRuleNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(horizontalRuleNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(horizontalRuleNodeMap['id'], nodeId);
  });

  test('ImageNode should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();

    final originalNode = ImageNode(
        id: nodeId,
        imageUrl: 'www.image.com/bla',
        altText: 'Shows a bla',
        metadata: {'blockType': '[NamedAttribution]: image'});

    var imageNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(imageNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(imageNodeMap['id'], nodeId);
  });

  test('ListItemNode.ordered should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();
    String testText = 'test_text';
    List<SpanMarker> markers = [];
    markers.add(const SpanMarker(
        attribution: NamedAttribution('header1'),
        offset: 1,
        markerType: SpanMarkerType.start));

    final originalNode = ListItemNode(
        id: nodeId,
        itemType: ListItemType.ordered,
        text: AttributedText(
            text: testText,
            spans: AttributedSpans(attributions: markers),),
            metadata: {'blockType': '[NamedAttribution]: paragraph'},
        indent: 1);

    var listItemNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(listItemNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(listItemNodeMap['id'], nodeId);
  });

  test('ListItemNode.unordered should serialize to Map and back again', () {
    String nodeId = DocumentEditor.createNodeId();
    String testText = 'test_text';
    List<SpanMarker> markers = [];
    markers.add(const SpanMarker(
        attribution: NamedAttribution('header1'),
        offset: 1,
        markerType: SpanMarkerType.start));

    final originalNode = ListItemNode(
        id: nodeId,
        itemType: ListItemType.unordered,
        text: AttributedText(
          text: testText,
          spans: AttributedSpans(attributions: markers),),
        metadata: {'blockType': '[NamedAttribution]: paragraph'},
        indent: 1);

    var listItemNodeMap = originalNode.toMap();

    var newNode = DocumentNodeSerialization.nodeFromMap(listItemNodeMap);
    expect(newNode != null, true);
    expect(newNode!.hasEquivalentContent(originalNode),true);
    expect(listItemNodeMap['id'], nodeId);
  });
}
