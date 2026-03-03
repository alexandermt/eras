unit uDMSnapshot;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, MySQLUniProvider,
  System.JSON;

type
  TDMSnapshot = class(TDataModule)
    qrySnapshots:           TUniQuery;
    dsSnapshots:            TDataSource;
    qrySnapshotApplicants:  TUniQuery;
  private
    { Private declarations }
  public
    procedure LoadSnapshots(AWorkspaceID: Integer);
    function  CreateSnapshot(AWorkspaceID: Integer; ALabel: string;
      ACreatedBy: Integer): Integer;
    procedure FreezeSnapshot(ASnapshotID, AUserID: Integer);
    function  IsSnapshotFrozen(ASnapshotID: Integer): Boolean;
  end;

var
  DMSnapshot: TDMSnapshot;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uDMMain, uDMOracle, uDMRankings, uAuditLogger, uDMAudit, uSessionManager;

{$R *.dfm}

{ TDMSnapshot }

procedure TDMSnapshot.LoadSnapshots(AWorkspaceID: Integer);
begin
  qrySnapshots.Close;
  qrySnapshots.Connection := DMMain.Instance.conMariaDB;
  qrySnapshots.SQL.Text :=
    'SELECT s.*, u.display_name AS created_by_name ' +
    'FROM   snapshots s ' +
    'JOIN   users u ON u.id = s.created_by ' +
    'WHERE  s.workspace_id = :workspace_id ' +
    'ORDER  BY s.created_at DESC';
  qrySnapshots.ParamByName('workspace_id').AsInteger := AWorkspaceID;
  qrySnapshots.Open;
end;

function TDMSnapshot.CreateSnapshot(AWorkspaceID: Integer; ALabel: string;
  ACreatedBy: Integer): Integer;
var
  LSnapshotID: Integer;
  LApplicantsJSON: string;
  LArr: TJSONArray;
  LItem: TJSONValue;
  LObj: TJSONObject;
  LOracleRef: string;
  LInsertApp, LInsertRank: TUniQuery;
  LWorkspaceQuery: TUniQuery;
  LCycle: Integer;
  LProgramme: string;
begin
  // Get workspace cycle_year and programme
  LWorkspaceQuery := TUniQuery.Create(nil);
  try
    LWorkspaceQuery.Connection := DMMain.Instance.conMariaDB;
    LWorkspaceQuery.SQL.Text :=
      'SELECT cycle_year, programme FROM workspaces WHERE id = :id';
    LWorkspaceQuery.ParamByName('id').AsInteger := AWorkspaceID;
    LWorkspaceQuery.Open;
    LCycle     := LWorkspaceQuery.FieldByName('cycle_year').AsInteger;
    LProgramme := LWorkspaceQuery.FieldByName('programme').AsString;
    LWorkspaceQuery.Close;
  finally
    LWorkspaceQuery.Free;
  end;

  // Insert snapshot record
  LInsertApp := TUniQuery.Create(nil);
  try
    LInsertApp.Connection := DMMain.Instance.conMariaDB;
    LInsertApp.SQL.Text :=
      'INSERT INTO snapshots (workspace_id, label, created_by) ' +
      'VALUES (:workspace_id, :label, :created_by)';
    LInsertApp.ParamByName('workspace_id').AsInteger := AWorkspaceID;
    LInsertApp.ParamByName('label').AsString         := ALabel;
    LInsertApp.ParamByName('created_by').AsInteger   := ACreatedBy;
    LInsertApp.ExecSQL;
    LSnapshotID := DMMain.Instance.conMariaDB.GetLastInsertId;
    Result := LSnapshotID;
  finally
    LInsertApp.Free;
  end;

  // Fetch applicants from Oracle
  LApplicantsJSON := DMOracle.GetApplicantsJSON(LCycle, LProgramme, 10000, 0);
  LArr := TJSONObject.ParseJSONValue(LApplicantsJSON) as TJSONArray;
  if LArr = nil then
    raise Exception.Create('Failed to parse Oracle applicants data');
  try
    LInsertApp := TUniQuery.Create(nil);
    LInsertRank := TUniQuery.Create(nil);
    try
      LInsertApp.Connection  := DMMain.Instance.conMariaDB;
      LInsertRank.Connection := DMMain.Instance.conMariaDB;
      for LItem in LArr do
      begin
        LObj      := LItem as TJSONObject;
        LOracleRef := LObj.GetValue('applicant_id').Value;
        // Insert snapshot_applicant
        LInsertApp.SQL.Text :=
          'INSERT INTO snapshot_applicants (snapshot_id, oracle_ref, applicant_data) ' +
          'VALUES (:snapshot_id, :oracle_ref, :applicant_data)';
        LInsertApp.ParamByName('snapshot_id').AsInteger    := LSnapshotID;
        LInsertApp.ParamByName('oracle_ref').AsString      := LOracleRef;
        LInsertApp.ParamByName('applicant_data').AsString  := LObj.ToJSON;
        LInsertApp.ExecSQL;
        // Insert rankings row with status=pending
        LInsertRank.SQL.Text :=
          'INSERT INTO rankings (snapshot_id, oracle_ref, status, last_updated_by) ' +
          'VALUES (:snapshot_id, :oracle_ref, ''pending'', :user_id)';
        LInsertRank.ParamByName('snapshot_id').AsInteger := LSnapshotID;
        LInsertRank.ParamByName('oracle_ref').AsString   := LOracleRef;
        LInsertRank.ParamByName('user_id').AsInteger     := ACreatedBy;
        LInsertRank.ExecSQL;
      end;
    finally
      LInsertApp.Free;
      LInsertRank.Free;
    end;
  finally
    LArr.Free;
  end;

  AuditLog('snapshot.create', LSnapshotID, 'snapshot', IntToStr(LSnapshotID), ALabel);
end;

procedure TDMSnapshot.FreezeSnapshot(ASnapshotID, AUserID: Integer);
var
  LUpd: TUniQuery;
begin
  if IsSnapshotFrozen(ASnapshotID) then
    raise Exception.Create('Snapshot is already frozen');
  LUpd := TUniQuery.Create(nil);
  try
    LUpd.Connection := DMMain.Instance.conMariaDB;
    LUpd.SQL.Text :=
      'UPDATE snapshots ' +
      'SET    frozen = TRUE, frozen_at = NOW() ' +
      'WHERE  id = :id';
    LUpd.ParamByName('id').AsInteger := ASnapshotID;
    LUpd.ExecSQL;
    AuditLog('snapshot.freeze', ASnapshotID, 'snapshot', IntToStr(ASnapshotID));
  finally
    LUpd.Free;
  end;
end;

function TDMSnapshot.IsSnapshotFrozen(ASnapshotID: Integer): Boolean;
var
  LQry: TUniQuery;
begin
  Result := False;
  LQry := TUniQuery.Create(nil);
  try
    LQry.Connection := DMMain.Instance.conMariaDB;
    LQry.SQL.Text :=
      'SELECT frozen FROM snapshots WHERE id = :id';
    LQry.ParamByName('id').AsInteger := ASnapshotID;
    LQry.Open;
    if not LQry.IsEmpty then
      Result := LQry.FieldByName('frozen').AsBoolean;
    LQry.Close;
  finally
    LQry.Free;
  end;
end;

end.
