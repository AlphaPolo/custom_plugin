import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:custom_plugin/src/rules/require_res_file_for_remote_image_manager.dart';

import 'src/assist/unwrap_res_file.dart';
import 'src/assist/wrap_with_res_file.dart';
import 'src/diagnostics.dart' as diag;
import 'src/fix/wrap_file_name_with_res_file.dart';

final plugin = SimplePlugin();

class SimplePlugin extends Plugin {

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(RequireResFileForRemoteImageManager());
    registry.registerFixForRule(diag.requireResFileForRemoteImageManager, WrapFileNameWithResFile.new);
    registry.registerAssist(WrapWithResFile.new);
    registry.registerAssist(UnwrapResFile.new);
  }

  @override
  String get name => 'simple_plugin';
}
