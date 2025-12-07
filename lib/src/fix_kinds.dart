import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';
import 'constants.dart';

/// IDE 右鍵選單裡顯示的文字
const wrapWithResFileAssistKind = AssistKind(
  'wrap_with_res_file', // id, 要唯一
  0,                   // 優先度，數字越小排越前
  "Wrap with '$kTypeResFile'",// 顯示在 IDE 的文字
);

const unwrapResFileAssistKind = AssistKind(
  'unwrap_res_file',
  1,
  "Unwrap '$kTypeResFile'",
);

const FixKind fixWrapResFileAtFilenameFixKind = FixKind(
  'fix_wrap_res_file_at_filename',
  0,
  "Wrap fileName with '$kTypeResFile'",
);
