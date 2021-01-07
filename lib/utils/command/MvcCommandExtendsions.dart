import 'package:id_mvc_app_framework/command.dart';

import 'MvcCommand.dart';
import 'MvcCommandManager.dart';

extension SingleCmdExt on MvcCommand {
  SingleCmd after({
    CmdRunner cmd,
    MvcCommandParams params,
  }) {
    return SingleCmd(cmd: this, after: cmd, params: params);
  }

  PeriodicCmd periodic({
    Duration interval,
    dynamic stopIf,
    MvcCommandParams params,
  }) {
    return PeriodicCmd(
      cmd: this,
      params: params,
      interval: interval,
      stopIf: stopIf,
    );
  }

  IfCmd ifc({
    MvcCommandParams params,
    CmdRunner ifTrue,
    CmdRunner ifFalse,
    CmdRunner ifNull,
  }) {
    return IfCmd(
      cmd: this,
      params: params,
      ifTrue: ifTrue,
      ifFalse: ifFalse,
      ifNull: ifNull,
    );
  }
}

extension MultiCmdExt on List<MvcCommand> {
  MultiCmd multi({
    MultiCmdMode mode = MultiCmdMode.sequence,
    MultiCmdAfterMode waitMode = MultiCmdAfterMode.waitAll,
    CmdRunner after,
  }) {
    return MultiCmd(
      cmds: this,
      after: after,
      mode: mode,
      waitMode: waitMode,
    );
  }
}
