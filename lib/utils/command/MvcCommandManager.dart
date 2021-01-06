import 'package:flutter/foundation.dart';
import 'package:id_mvc_app_framework/framework.dart';
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
  CmdRunner()
      : super(
          func: null,
        );

  @override
  @mustCallSuper
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    MvcCommandManager()._currentRunner[workflowState._workflow] = this;
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
  }) : assert(cmd != null);

  @override
  Future<void> executeCommand([MvcCmdWorkflowState workflowState]) async {
    super.executeCommand(workflowState);
    await Future.doWhile(() async {
      await Future.delayed(EXEC_TRIAL_INTERVAL.milliseconds);
      return !cmd.canExecute;
    });
    workflowState.lastCommandResult = await cmd.executeWithFuture(params);
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

class MvcCmdWorkflowState extends MvcCommandParams {
  String _workflow;
  MvcCommandResult lastCommandResult;
}
