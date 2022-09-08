import 'package:super_editor/super_editor.dart';

/// Contains methods used to serialize and deserialize [DocumentNode]s into [Map<String,dynamic>].
class DocumentNodeSerialization {
  // Strings used as Map keys for serializing nodes using primitive types
  static const String _id = 'id';
  static const String _type = 'type';
  static const String _metadata = 'metadata';
  static const String _attributedText = 'attributedText';
  static const String _markerType = 'markerType';
  static const String _attributionName = 'attributionName';
  static const String _offset = 'offset';
  static const String _markerMaps = 'markerMaps';
  static const String _text = 'text';
  static const String _imageUrl = 'imageUrl';
  static const String _altText = 'altText';
  static const String _listItemType = 'listItemType';
  static const String _indent = 'indent';

  // Strings used to serialize runtime types of [DocumentNode]s.
  static const String _textNode = 'TextNode';
  static const String _paragraphNode = 'ParagraphNode';
  static const String _horizontalRuleNode = 'HorizontalRuleNode';
  static const String _imageNode = 'ImageNode';
  static const String _listItemNode = 'ListItemNode';

  static const String _nullValueErrorString = 'is null, cannot create nodeMap.';

  /// Converts the [DocumentNode] into a Map<String,dynamic>.
  static Map<String, dynamic> nodeToMap(DocumentNode node) {
    Map<String, dynamic> nodeMap = {};

    switch (node.runtimeType) {
      case TextNode:
        TextNode thisNode = node as TextNode;
        nodeMap = _nodeContentToMap(
            id: node.id,
            type: node.runtimeType,
            attributedText: thisNode.text,
            metadata: thisNode.copyMetadata());
        break;
      case ParagraphNode:
        ParagraphNode thisNode = node as ParagraphNode;
        nodeMap = _nodeContentToMap(
            id: node.id,
            type: node.runtimeType,
            attributedText: thisNode.text,
            metadata: thisNode.copyMetadata());
        break;
      case HorizontalRuleNode:
        nodeMap = _nodeContentToMap(id: node.id, type: node.runtimeType);
        break;
      case ImageNode:
        ImageNode thisNode = node as ImageNode;
        nodeMap = _nodeContentToMap(
            id: node.id,
            type: node.runtimeType,
            imageUrl: thisNode.imageUrl,
            altText: thisNode.altText,
            metadata: thisNode.copyMetadata());
        break;
      case ListItemNode:
        ListItemNode thisNode = node as ListItemNode;
        nodeMap = _nodeContentToMap(
            id: node.id,
            type: node.runtimeType,
            listItemType:
                node.type == ListItemType.ordered ? 'ordered' : 'unordered',
            indent: thisNode.indent,
            attributedText: thisNode.text,
            metadata: thisNode.copyMetadata());
        break;
      default:
        break;
    }
    return nodeMap;
  }

  static Map<String, dynamic> _nodeContentToMap(
      {required String id,
      required Type type,
      Map<String, dynamic>? metadata,
      AttributedText? attributedText,
      String? imageUrl,
      String? altText,
      String? listItemType,
      int? indent}) {
    Map<String, dynamic> nodeMap = {};
    nodeMap[_id] = id;
    nodeMap[_type] = _runtimeTypeToString(type);

    if (metadata != null) nodeMap[_metadata] = metadata;

    List<Map<String, dynamic>> markerMaps = [];
    if (attributedText != null) {
      for (var marker in attributedText.spans.markers) {
        SpanMarkerType markerType = marker.markerType;
        NamedAttribution attribution = marker.attribution as NamedAttribution;
        int offset = marker.offset;
        Map<String, dynamic> markerMap = {
          _markerType: markerType == SpanMarkerType.start ? 'start' : 'end',
          _attributionName: attribution.name,
          _offset: offset
        };
        markerMaps.add(markerMap);
      }
      nodeMap[_attributedText] = {
        _markerMaps: markerMaps,
        _text: attributedText.text
      };
    }

    if (type == ImageNode) {
      if (imageUrl == null) {
        throw ArgumentError('imageUrl $_nullValueErrorString');
      }
      if (altText == null) {
        throw ArgumentError('altText $_nullValueErrorString');
      }
      nodeMap[_imageUrl] = imageUrl;
      nodeMap[_altText] = altText;
    }

    if (type == ListItemNode) {
      if (listItemType == null) {
        throw ArgumentError('listItemType $_nullValueErrorString');
      }
      if (indent == null) throw ArgumentError('indent $_nullValueErrorString');
      nodeMap[_listItemType] = listItemType;
      nodeMap[_indent] = indent;
    }

    return nodeMap;
  }

  /// Serializes the runtime type to a String.
  static String _runtimeTypeToString(Type type) {
    switch (type) {
      case TextNode:
        return _textNode;
      case ParagraphNode:
        return _paragraphNode;
      case HorizontalRuleNode:
        return _horizontalRuleNode;
      case ImageNode:
        return _imageNode;
      case ListItemNode:
        return _listItemNode;
      default:
        throw ArgumentError.value(type,
            'Unacceptable Type passed as an argument. Only TextNode, ParagraphNode, HorizontalRuleNode, ImageNode and ListItemNode are accepted.');
    }
  }

  /// This converts a map into a [DocumentNode]. Currently it only returns a TextNode.
  static DocumentNode? nodeFromMap(Map<String, dynamic> nodeMap) {
    // Used by all node types
    var id = _typeCheckString(nodeMap, _id);
    var type = _typeCheckString(nodeMap, _type);

    // Used by TextNode, ParagraphNode and ListItemNode
    String? text;
    List<SpanMarker>? spanMarkers;

    if (nodeMap.containsKey(_attributedText)) {
      var attributedText = _typeCheckMap(nodeMap, _attributedText);
      text = _typeCheckString(attributedText, _text);
      var markerMaps = _typeCheckListOfMaps(attributedText, _markerMaps);

      spanMarkers = [];
      for (Map<String, dynamic> marker in markerMaps) {
        String attributionName = _typeCheckString(marker, _attributionName);
        int offset = _typeCheckInt(marker, _offset);
        String markerType = _typeCheckString(marker, _markerType);

        spanMarkers.add(SpanMarker(
            attribution: NamedAttribution(attributionName),
            offset: offset,
            markerType: markerType == 'start'
                ? SpanMarkerType.start
                : SpanMarkerType.end));
      }
    }

    switch (type) {
      case _textNode:
        _nullCheck(_text, text);
        _nullCheck('spanMarkers', spanMarkers);
        return TextNode(
            id: id,
            text: AttributedText(
                text: text!, spans: AttributedSpans(attributions: spanMarkers)),
            metadata: _typeCheckMap(nodeMap, _metadata));
      case _paragraphNode:
        _nullCheck(_text, text);
        _nullCheck('spanMarkers', spanMarkers);
        return ParagraphNode(
            id: id,
            text: AttributedText(
                text: text!, spans: AttributedSpans(attributions: spanMarkers)),
            metadata: _typeCheckMap(nodeMap, _metadata));
      case _horizontalRuleNode:
        return HorizontalRuleNode(id: id);
      case _imageNode:
        return ImageNode(
            id: id,
            imageUrl: _typeCheckString(nodeMap, _imageUrl),
            altText: _typeCheckString(nodeMap, _altText),
            metadata: _typeCheckMap(nodeMap, _metadata));
      case _listItemNode:
        _nullCheck(_text, text);
        _nullCheck('spanMakers', spanMarkers);
        return ListItemNode(
            id: id,
            itemType: _typeCheckString(nodeMap, _listItemType) == 'ordered'
                ? ListItemType.ordered
                : ListItemType.unordered,
            text: AttributedText(
                text: text!, spans: AttributedSpans(attributions: spanMarkers)),
            metadata: _typeCheckMap(nodeMap, _metadata),
            indent: _typeCheckInt(nodeMap, _indent));
      default:
        return null;
    }
  }

  // Error methods

  static _nullCheck(String key, dynamic value) {
    if (value == null) {
      throw ArgumentError(
          '$key is null in passed nodeMap, cannot create DocumentNode.');
    }
  }

  static Map<String, dynamic> _typeCheckMap(Map map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError(
          '$key is null in passed nodeMap, cannot create DocumentNode.');
    }
    if (map[key] is! Map<String, dynamic>) {
      throw ArgumentError(
          '$key was an invalid type. Was: ${map[key].runtimeType} Expected: Map<String,dynamic>');
    }
    return map[key];
  }

  static int _typeCheckInt(Map map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError(
          '$key is null in passed nodeMap, cannot create DocumentNode.');
    }
    if (map[key] is! int) {
      throw ArgumentError(
          '$key was an invalid type. Was: ${map[key].runtimeType} Expected: int');
    }
    return map[key];
  }

  static String _typeCheckString(Map map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError(
          '$key is null in passed nodeMap, cannot create DocumentNode.');
    }
    if (map[key] is! String) {
      throw ArgumentError(
          '$key was an invalid type. Was: ${map[key].runtimeType} Expected: String');
    }
    return map[key];
  }

  static List<Map<String, dynamic>> _typeCheckListOfMaps(Map map, String key) {
    if (!map.containsKey(key)) {
      throw ArgumentError(
          '$key is null in passed nodeMap, cannot create DocumentNode.');
    }
    if (map[key] is! List<Map<String, dynamic>>) {
      throw ArgumentError(
          '$key was an invalid type. Was: ${map[key].runtimeType} Expected: List<Map<String,dynamic>>');
    }
    return map[key];
  }
}
