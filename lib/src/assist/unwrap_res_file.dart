import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:custom_plugin/src/constants.dart';

import 'package:custom_plugin/src/fix_kinds.dart';

/// 將 `ResFile("xxx")` 拆成 `"xxx"`
class UnwrapResFile extends ResolvedCorrectionProducer {
  UnwrapResFile({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  AssistKind get assistKind => unwrapResFileAssistKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (creation == null) return;

    final typeNode = creation.constructorName.type;
    final token = typeNode.name; // Token
    final typeName = token.lexeme; // "ResFile"

    if (typeName != kTypeResFile) {
      return;
    }

    final args = creation.argumentList.arguments;
    if (args.length != 1) return;

    // 不再限制一定要是 StringLiteral，任何 expression 都可以 unwrap
    final innerExpr = args.first;

    // 原始程式碼（可能是 'ic_gift'、icGift、getName() 等）
    final innerText = utils.getNodeText(innerExpr);

    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        innerText,
      );
    });
  }
}
