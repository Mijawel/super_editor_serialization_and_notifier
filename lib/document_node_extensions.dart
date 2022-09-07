import 'package:super_editor/super_editor.dart';

extension DocumentNodeExtensions on DocumentNode {

  /// Converts the [DocumentNode] into a Map<String,dynamic>.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> nodeMap = {};
    switch (runtimeType) {
      case TextNode:
        TextNode thisNode = this as TextNode;
        String plainText = thisNode.text.text;
        AttributedSpans attributedSpans = thisNode.text.spans;
        List<SpanMarker> markers = attributedSpans.markers;

        List<Map<String, dynamic>> markerMaps = [];
        for (var marker in markers) {
          SpanMarkerType markerType = marker.markerType;
          Attribution attribution = marker.attribution;
          int offset = marker.offset;
          Map<String, dynamic> markerMap = {
            'markerType': markerType.toString(),
            'attributionID': attribution.id,
            'offset': offset
          };
          markerMaps.add(markerMap);
        }

        nodeMap['nodeType'] = 'TextNode';
        nodeMap['attributedText'] = {
          'markerMaps': markerMaps,
          'text': plainText
        };
        nodeMap['metaData'] = thisNode.copyMetadata();
        nodeMap['id'] = thisNode.id;
        break;
      case ParagraphNode:
        break;
      case HorizontalRuleNode:
        break;
      case BlockNode:
        break;
      case ImageNode:
        break;
      case ListItemNode:
        break;
      case DocumentNode:
        break;
      default:
        break;
    }
    return nodeMap;
  }

  /// This converts a map into a [DocumentNode]. Currently it only returns a TextNode.
  static DocumentNode fromMap(Map<String, dynamic> nodeMap) {
    assert(nodeMap['nodeType'] == 'TextNode');

    List<SpanMarker> spanMarkers = [];
    for (var marker in nodeMap['attributedText']['markerMaps']) {
      spanMarkers.add(SpanMarker(
          attribution: NamedAttribution(marker['attributionID']),
          offset: marker['offset'],
          markerType: marker['markerType'] == 'start'
              ? SpanMarkerType.start
              : SpanMarkerType.end));
    }
    return TextNode(
        id: nodeMap['id'],
        text: AttributedText(
            text: nodeMap['attributedText']['text'],
            spans: AttributedSpans(attributions: spanMarkers)),
        metadata: nodeMap['metaData']);
  }

}

