import 'package:flutter/foundation.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'MvcCommand.dart';

const int EXEC_TRIAL_INTERVAL = 10;

class MvcCommandManager with GetxServiceMixin {
  factory MvcCommandManager() => Get.put(MvcCommandManager._());
  MvcCommandManager._();
  final Map<String, WorkflowEntryPoint> _workflows = Map();

  final Map<String, CmdRunner> _currentRunner = Map();

  WorkflowEntryPoint wf<TState extends MvcCmdWorkflowState>(
      String name, TState initState) {
    if (!_workflows.containsKey(name)) {
      _workflows[name] = WorkflowEntryPoint<TState>(initState);
      initState._workflow = name;
    }
    return _workflows[name];
  }

  void start(String workflow) async {
    assert(_workflows.containsKey(workflow),
        "Workflow [$workflow] is not configured. Please use [wf] method to setup");
    WorkflowEntryPoint entryPoint = _workflows[workflow];
    await entryPoint.execute(entryPoint.workflowState);
  }
}

abstract class CmdRunner<TState extends MvcCmdWorkflowState> {
  @protected
  @mustCallSuper
  Future<void> execute(TState workflowState) async {
    MvcCommandManager()._currentRunner[workflowState._workflow] = this;
  }
}

class SingleCmd<TState extends MvcCmdWorkflowState> extends CmdRunner<TState> {
  final MvcCommand cmd;
  final CmdRunner<TState> after;
  final MvcCommandParams params;

  SingleCmd({
    this.cmd,
    this.after,
    this.params,
  }) : assert(cmd != null);

  @override
  Future<void> execute(TState workflowState) async {
    super.execute(workflowState);
    await Future.doWhile(() async {
      await Future.delayed(EXEC_TRIAL_INTERVAL.milliseconds);
      return !cmd.canExecute;
    });
    workflowState.lastCommandResult = await cmd.executeWithFuture(params);
    if (after != null) after.execute(workflowState);
  }
}

class WorkflowEntryPoint<TState extends MvcCmdWorkflowState>
    extends CmdRunner<TState> {
  final TState workflowState;
  CmdRunner<TState> cmd;

  WorkflowEntryPoint(this.workflowState);

  void exec(CmdRunner cmd) {
    this.cmd = cmd;
  }

  @override
  Future<void> execute(TState workflowState) async {
    assert(cmd != null, "Make sure you start workflow with [exec] command.");
    super.execute(workflowState);
    await cmd.execute(workflowState);
  }
}

abstract class MvcCmdWorkflowState {
  String _workflow;
  MvcCommandResult lastCommandResult;
}
