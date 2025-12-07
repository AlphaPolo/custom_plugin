// lib/src/fixes/wrap_file_name_with_res_file.dart

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'package:custom_plugin/src/constants.dart';
import 'package:custom_plugin/src/fix_kinds.dart';

import '../diagnostics.dart' as diag;

/// 參考自 WrapInText
/// https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/lib/src/services/correction/dart/wrap_in_text.dart
class WrapFileNameWithResFile extends ResolvedCorrectionProducer {
  WrapFileNameWithResFile({required super.context});

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  FixKind get fixKind => fixWrapResFileAtFilenameFixKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // 1. 只處理自家這個 lint
    // final diagnosticCode = diagnostic;

    // if (diagnosticCode != diag.requireResFileForRemoteImageManager) {
    //   return;
    // }

    // 2. rule.reportAtNode(expr) 報錯 → 這裡的 node 就是那個 expr
    final expr = node;
    if (expr is! Expression) return;

    // 我們只處理可以直接包的情況（通常是 StringLiteral）
    // 如果你想對所有 expression 都開放，也可以不檢查 type
    // if (expr is! StringLiteral) return;

    final originalText = utils.getNodeText(expr); // 例如 "'bg_banner'"

    await builder.addDartFileEdit(file, (fileBuilder) {
      fileBuilder.addSimpleReplacement(
        SourceRange(expr.offset, expr.length),
        '$kTypeResFile($originalText)',
      );
    });
  }
}
