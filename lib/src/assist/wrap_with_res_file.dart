// lib/src/assist/wrap_with_res_file.dart
import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:custom_plugin/src/constants.dart';
import 'package:custom_plugin/src/fix_kinds.dart';
import 'package:analyzer/src/dart/ast/extensions.dart';
import 'package:analyzer_plugin/utilities/range_factory.dart';


class WrapWithResFile extends ResolvedCorrectionProducer {
  WrapWithResFile({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  // @override
  // FixKind get fixKind => wrapWithResFileFixKind;

  @override
  AssistKind get assistKind => wrapWithResFileAssistKind;

  // @override
  // Future<void> compute(ChangeBuilder builder) async {
  //   // 找到目前 cursor / 診斷位置附近最近的 StringLiteral
  //   final literal = node.thisOrAncestorOfType<StringLiteral>();
  //   if (literal == null) return;
  //
  //   // 字面值的原始文字 (包含引號)
  //   final literalText = utils.getNodeText(literal);
  //
  //   await builder.addDartFileEdit(file, (fileBuilder) {
  //     fileBuilder.addSimpleReplacement(
  //       SourceRange(literal.offset, literal.length),
  //       '$kTypeResFile($lit  eralText)',
  //     );
  //   });
  // }

  @override
  Future<void> compute(ChangeBuilder builder) async {

    // 1. 先找到最近的 Expression
    final rawExpr = node.thisOrAncestorOfType<Expression>();
    if (rawExpr == null) return;

    // 2. 擴展成完整的成員存取表達式
    final expr = _expandToFullAccess(rawExpr);

    // 3. 型別檢查（如果你有的話）
    final type = expr.typeOrThrow;
    // 如果型別資訊有時拿不到，可以加個 null check 或保留你原本的判斷
    if (!type.isDartCoreString) {
      // 或你只想限定 StringLiteral 就改成 (expr is! StringLiteral)
      // 依你需求調整
      return;
    }

    final exprText = utils.getNodeText(expr);

    // 4. 建立編輯：把 expression 包成 ResFile(...)
    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addSimpleReplacement(
        range.node(expr),
        '$kTypeResFile($exprText)',
      );
    });
  }

  // static _Context? _extractContextInformation(AstNode node) {
  //   if (node is! Expression) return null;
  //   if (!node.typeOrThrow.isDartCoreString) return null;
  //   return _Context(stringExpression: node);
  // }

  /// 如果游標在 `orderReset`，但 parent 是
  ///   - `PrefixedIdentifier(HomeStaticImage.orderReset)`
  ///   - 或 `PropertyAccess(HomeStaticImage.orderReset)`
  /// 就把要操作的節點提到 parent 上。
  Expression _expandToFullAccess(Expression expr) {
    final parent = expr.parent;

    // 舊版 AST：static 成員存取多半是 PrefixedIdentifier
    if (parent is PrefixedIdentifier && parent.identifier == expr) {
      return parent;
    }

    // 另一些情況會是 PropertyAccess
    if (parent is PropertyAccess && parent.propertyName == expr) {
      return parent;
    }

    return expr;
  }
}

class _Context {
  final Expression stringExpression;

  _Context({required this.stringExpression});
}
