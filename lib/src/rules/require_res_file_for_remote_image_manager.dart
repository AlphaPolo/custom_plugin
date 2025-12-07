
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:custom_plugin/src/constants.dart';



import '../diagnostics.dart' as diag;


const _desc = "Require '$kTypeResFile' for $kCallManagerAppendFtpPath $kArgFileName argument.";

class RequireResFileForRemoteImageManager extends AnalysisRule {
  RequireResFileForRemoteImageManager()
      : super(
    name: diag.requireResFileForRemoteImageManager.name,
    description: _desc,
  );

  @override
  DiagnosticCode get diagnosticCode => diag.requireResFileForRemoteImageManager;

  @override
  void registerNodeProcessors(
      RuleVisitorRegistry registry,
      RuleContext context,
      ) {
    var visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
    // registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // 1. 確認是 RemoteImageManager.appendFtpPath 的建構式
    final constructor = node.constructorName.element;
    if (constructor is! ConstructorElement) return;

    // class RemoteImageManager { factory RemoteImageManager.appendFtpPath(...) { ... } }
    final classElement = constructor.enclosingElement;
    if (classElement is! ClassElement ||
        classElement.name != '${kTypeRemoteImageManager}') {
      return;
    }

    final ctorName = constructor.name; // 'appendFtpPath' for RemoteImageManager.appendFtpPath
    if (ctorName != '${kFuncAppendFtpPath}') return;

    // 2. 找 named argument: fileName: ...
    NamedExpression? fileNameArg;
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == '${kArgFileName}') {
        fileNameArg = arg;
        break;
      }
    }
    if (fileNameArg == null) return;

    final expr = fileNameArg.expression;

    // 3. 已經是 ResFile(...) / 推導型別是 ResFile 的話就放過
    if (_isResFileExpression(expr)) {
      return;
    }

    // 4. 否則報 lint，標在 value 上
    rule.reportAtNode(expr);
  }

  bool _isResFileExpression(Expression expr) {
    // Type-based 檢查：fileName 推導型別就是 ResFile 或 ResFile?
    final type = expr.staticType;
    if (type is InterfaceType && type.element.name == '${kTypeResFile}') {
      return true;
    }

    // Fallback：語法上就是 ResFile(...)
    if (expr is InstanceCreationExpression) {
      final typeNode = expr.constructorName.type;
      final token = typeNode.name; // Token
      final typeName = token.lexeme; // "ResFile"

      if (typeName == '${kTypeResFile}') {
        return true;
      }
    }

    return false;
  }
}