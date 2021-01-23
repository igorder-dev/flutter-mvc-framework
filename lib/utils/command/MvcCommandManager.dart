import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/helpers.dart';
import 'MvcCommand.dart';

const int EXEC_TRIAL_INTERVAL = 10;

class MvcCommandManager with GetxServiceMixin {
  factory MvcCommandManager() => Get.put(MvcCommandManager._());
  MvcCommandManager._();
  final Map<String, WorkflowEntryPoint> _workflows = Map();

  final Map<String, CmdRunner> _currentRunner = Map();

  WorkflowEntryPoint wf(String name, [MvcCmdWorkflowState initState]) {
    if (!_workflows.containsKey(name)) {
      _workflows[name] = WorkflowEntryPoint(initState ?? MvcCmdWorkflowState());
      initState._workflow = name;
    }
    return _workflows[name];
  }

  void start(String workflow) {
    assert(_workflows.containsKey(workflow),
        "Workflow [$workflow] is not configured. Please use [wf] method to setup");
    WorkflowEntryPoint entryPoint = _workflows[workflow];
    entryPoint.execute(entryPoint.workflowState);
  }
}

abstract class CmdRunner extends MvcCommandAsync<MvcCmdWorkflowState, void> {
  CmdRunner({List<RxInterface> triggers})
      : super(
          func: null,
          autoReset: true,
          triggers: triggers,
        );

  @override
  @mustCallSuper
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    if (workflowState == null) return;
    MvcCommandManager()._currentRunner[workflowState._workflow] = this;
  }

  @protected
  Future<MvcCommandResult> runCmd(
      MvcCommand cmd, MvcCmdWorkflowState workflowState,
      [MvcCommandParams params]) async {
    cmd.resetCommand();
    await Future.doWhile(() async {
      await Future.delayed(EXEC_TRIAL_INTERVAL.milliseconds);
      return !cmd.canExecute;
    });

    var result = await cmd.executeWithFuture(params ?? workflowState);
    workflowState?.lastCommandResult = result;
    return result;
  }
}

class SingleCmd extends CmdRunner {
  final MvcCommand cmd;
  final CmdRunner after;
  final MvcCommandParams params;

  SingleCmd({
    this.cmd,
    this.after,
    this.params,
    List<RxInterface> triggers,
  })  : assert(cmd != null),
        super(triggers: triggers);

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    super.executeCommand(workflowState);
    await runCmd(cmd, workflowState, params);
    if (after != null) after.executeWithFuture(workflowState);
  }
}

class WorkflowEntryPoint extends CmdRunner {
  final MvcCmdWorkflowState workflowState;
  CmdRunner runner;

  WorkflowEntryPoint(this.workflowState);

  void exec(CmdRunner runner) {
    this.runner = runner;
  }

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    assert(runner != null, "Make sure you start workflow with [exec] command.");
    super.executeCommand(workflowState);
    await runner.executeWithFuture(workflowState);
  }
}

enum MultiCmdMode { sequence, parallel }
enum MultiCmdAfterMode { waitAll, waitAny }

class MultiCmd extends CmdRunner {
  final List<MvcCommand> cmds;
  final MultiCmdMode mode;
  final MultiCmdAfterMode waitMode;
  final CmdRunner after;
  final MvcCommandParams params;

  MultiCmd({
    this.cmds = const [],
    this.mode = MultiCmdMode.sequence,
    this.waitMode = MultiCmdAfterMode.waitAll,
    this.params,
    this.after,
    List<RxInterface> triggers,
  }) : super(triggers: triggers);

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    super.executeCommand(workflowState);
    switch (waitMode) {
      case MultiCmdAfterMode.waitAll:
        await _waitAll(workflowState);
        break;
      case MultiCmdAfterMode.waitAny:
        await _waitAny(workflowState);
        break;
    }
    if (after != null) after.executeWithFuture(workflowState);
  }

  Future<void> _waitAll(MvcCmdWorkflowState workflowState) async {
    switch (mode) {
      case MultiCmdMode.sequence:
        return await _executeSequence(workflowState);
      case MultiCmdMode.parallel:
        return await _executeParallel(workflowState);
    }
  }

  Future<void> _executeSequence(MvcCmdWorkflowState workflowState) async {
    for (var cmd in cmds) {
      await runCmd(cmd, workflowState);
    }
  }

  Future<void> _executeParallel(MvcCmdWorkflowState workflowState) async {
    List<Future<MvcCommandResult>> results = List();
    cmds.forEach((cmd) {
      results.add(cmd.executeWithFuture(params));
    });
    var list = await Future.wait(results);
    workflowState?.lastCommandResult = list.last;
  }

  Future<void> _waitAny(MvcCmdWorkflowState workflowState) async {
    List<Future<MvcCommandResult>> results = List();
    cmds.forEach((cmd) {
      results.add(cmd.executeWithFuture(params));
    });
    if (results.length > 0) {
      workflowState?.lastCommandResult = await Future.any(results);
    }
  }
}

class PeriodicCmd extends CmdRunner {
  final MvcCommand cmd;
  final MvcCommandParams params;
  final Duration interval;
  final dynamic stopIf;

  PeriodicCmd({
    @required this.cmd,
    @required this.interval,
    this.params,
    this.stopIf = false,
    List<RxInterface> triggers,
  })  : assert(cmd != null),
        assert(interval != null),
        super(triggers: triggers);

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    super.executeCommand(workflowState);
    while (!MvcHelpers.conditional(stopIf ?? false)) {
      await runCmd(cmd, workflowState, params);
      await Future.delayed(interval);
    }
  }
}

class IfCmd extends CmdRunner {
  final MvcCommand cmd;
  final MvcCommandParams params;
  final CmdRunner ifTrue;
  final CmdRunner ifFalse;
  final CmdRunner ifNull;

  IfCmd({
    this.cmd,
    this.params,
    this.ifTrue,
    this.ifFalse,
    this.ifNull,
    List<RxInterface> triggers,
  })  : assert(cmd != null),
        super(triggers: triggers);

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    super.executeCommand(workflowState);
    var cmdRes = await runCmd(cmd, workflowState, params);
    if (cmdRes.result is bool) {
      if (cmdRes.result) {
        await ifTrue?.executeWithFuture(workflowState);
      } else {
        await ifFalse?.executeWithFuture(workflowState);
      }
    } else {
      await (ifNull != null ? ifNull : ifTrue)
          ?.executeWithFuture(workflowState);
    }
  }
}

class MvcCmdWorkflowState extends MvcCommandParams {
  String _workflow;
  MvcCommandResult lastCommandResult;
}
