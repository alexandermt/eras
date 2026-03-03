unit uDMAudit;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, MySQLUniProvider;

type
  TDMAudit = class(TDataModule)
    qryAuditInsert: TUniQuery;
    qryAuditList:   TUniQuery;
  private
    { Private declarations }
  public
    procedure Log(AUserID: Integer; AAction: string;
      ASnapshotID: Integer = 0; AEntityType: string = '';
      AEntityID: string = ''; APayload: string = '');
    procedure LoadAuditLog(AWorkspaceID: Integer;
      AFromDate, AToDate: TDateTime);
  end;

var
  DMAudit: TDMAudit;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uDMMain;

{$R *.dfm}

procedure TDMAudit.Log(AUserID: Integer; AAction: string;
  ASnapshotID: Integer; AEntityType: string;
  AEntityID: string; APayload: string);
begin
  qryAuditInsert.Close;
  qryAuditInsert.SQL.Text :=
    'INSERT INTO audit_logs ' +
    '  (user_id, snapshot_id, action, entity_type, entity_id, payload) ' +
    'VALUES ' +
    '  (:user_id, :snapshot_id, :action, :entity_type, :entity_id, :payload)';
  qryAuditInsert.Connection := DMMain.Instance.conMariaDB;
  qryAuditInsert.ParamByName('user_id').AsInteger     := AUserID;
  if ASnapshotID > 0 then
    qryAuditInsert.ParamByName('snapshot_id').AsInteger := ASnapshotID
  else
    qryAuditInsert.ParamByName('snapshot_id').Clear;
  qryAuditInsert.ParamByName('action').AsString       := AAction;
  qryAuditInsert.ParamByName('entity_type').AsString  := AEntityType;
  qryAuditInsert.ParamByName('entity_id').AsString    := AEntityID;
  if APayload <> '' then
    qryAuditInsert.ParamByName('payload').AsString    := APayload
  else
    qryAuditInsert.ParamByName('payload').Clear;
  qryAuditInsert.ExecSQL;
end;

procedure TDMAudit.LoadAuditLog(AWorkspaceID: Integer;
  AFromDate, AToDate: TDateTime);
begin
  qryAuditList.Close;
  qryAuditList.SQL.Text :=
    'SELECT al.*, u.username, u.display_name ' +
    'FROM   audit_logs al ' +
    'JOIN   users u ON u.id = al.user_id ' +
    'WHERE  al.workspace_id = :workspace_id ' +
    '  AND  al.occurred_at BETWEEN :from_date AND :to_date ' +
    'ORDER  BY al.occurred_at DESC';
  qryAuditList.Connection := DMMain.Instance.conMariaDB;
  qryAuditList.ParamByName('workspace_id').AsInteger := AWorkspaceID;
  qryAuditList.ParamByName('from_date').AsDateTime   := AFromDate;
  qryAuditList.ParamByName('to_date').AsDateTime     := AToDate;
  qryAuditList.Open;
end;

end.
