import 'package:analyzer/error/error.dart';

import 'constants.dart';


const LintCode requireResFileForRemoteImageManager = LintCode(
  'require_resfile_for_remote_image_manager',
  "The '$kArgFileName' argument of '$kCallManagerAppendFtpPath' should use '$kTypeResFile'.",
  correctionMessage: "Try wrapping the value in '$kTypeResFile(...)'.",
  // severity: .ERROR,
);