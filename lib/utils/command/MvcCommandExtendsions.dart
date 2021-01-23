import 'package:get/get.dart';
import 'package:id_mvc_app_framework/command.dart';

import 'MvcCommand.dart';
import 'MvcCommandManager.dart';

extension SingleCmdExt on MvcCommand {
  SingleCmd after({
    CmdRunner cmd,
    MvcCommandParams params,
    List<RxInterface> triggers,
  }) {
    return SingleCmd(
      cmd: this,
      after: cmd,
      params: params,
      triggers: triggers,
    );
  }

  PeriodicCmd periodic({
    Duration interval,
    dynamic stopIf,
    MvcCommandParams params,
    List<RxInterface> triggers,
  }) {
    return PeriodicCmd(
      cmd: this,
      params: params,
      interval: interval,
      stopIf: stopIf,
      triggers: triggers,
    );
  }

  IfCmd ifc({
    MvcCommandParams params,
    CmdRunner ifTrue,
    CmdRunner ifFalse,
    CmdRunner ifNull,
    List<RxInterface> triggers,
  }) {
    return IfCmd(
      cmd: this,
      params: params,
      ifTrue: ifTrue,
      ifFalse: ifFalse,
      ifNull: ifNull,
      triggers: triggers,
    );
  }
}

extension MultiCmdExt on List<MvcCommand> {
  MultiCmd multi({
    MultiCmdMode mode = MultiCmdMode.sequence,
    MultiCmdAfterMode waitMode = MultiCmdAfterMode.waitAll,
    CmdRunner after,
    List<RxInterface> triggers,
  }) {
    return MultiCmd(
      cmds: this,
      after: after,
      mode: mode,
      waitMode: waitMode,
      triggers: triggers,
    );
  }
}
