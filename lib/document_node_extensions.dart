import 'package:super_editor/super_editor.dart';

extension DocumentNodeExtensions on DocumentNode {
  DocumentNode deepCopy() {
    switch(runtimeType) {
      case TextNode:
        TextNode(id: id, text: this.);
        AttributedText();
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
  }
}