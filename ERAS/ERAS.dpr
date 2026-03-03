program ERAS;

uses
  SysUtils,
  UniGUIApplication,
  uDMMain in 'DataModules\uDMMain.pas' {DMMain: TDataModule},
  uDMOracle in 'DataModules\uDMOracle.pas' {DMOracle: TDataModule},
  uDMWorkspace in 'DataModules\uDMWorkspace.pas' {DMWorkspace: TDataModule},
  uDMSnapshot in 'DataModules\uDMSnapshot.pas' {DMSnapshot: TDataModule},
  uDMRankings in 'DataModules\uDMRankings.pas' {DMRankings: TDataModule},
  uDMAudit in 'DataModules\uDMAudit.pas' {DMAudit: TDataModule},
  uMainForm in 'Forms\uMainForm.pas' {MainForm: TUniForm},
  uLoginForm in 'Forms\uLoginForm.pas' {LoginForm: TUniForm},
  uWorkspaceForm in 'Forms\uWorkspaceForm.pas' {WorkspaceForm: TUniForm},
  uSnapshotForm in 'Forms\uSnapshotForm.pas' {SnapshotForm: TUniForm},
  uRankingForm in 'Forms\uRankingForm.pas' {RankingForm: TUniForm},
  uExportForm in 'Forms\uExportForm.pas' {ExportForm: TUniForm},
  uAppConfig in 'Core\uAppConfig.pas',
  uSessionManager in 'Core\uSessionManager.pas',
  uAuditLogger in 'Core\uAuditLogger.pas',
  uJSONHelper in 'Core\uJSONHelper.pas',
  uConstants in 'Core\uConstants.pas';

{$R *.res}

begin
  UniGUIRunService(TUniGUIApplication);
end.
