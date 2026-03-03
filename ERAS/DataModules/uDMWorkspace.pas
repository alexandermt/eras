unit uDMWorkspace;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, MySQLUniProvider;

type
  TDMWorkspace = class(TDataModule)
    qryWorkspaces:      TUniQuery;
    dsWorkspaces:       TDataSource;
    qryWorkspaceDetail: TUniQuery;
  private
    { Private declarations }
  public
    procedure LoadWorkspaces(AUserID: Integer);
    function  CreateWorkspace(AName, AProgramme: string;
      ACycleYear, AOwnerID: Integer): Integer;
    procedure SoftDeleteWorkspace(AWorkspaceID, AUserID: Integer);
    procedure UpdateWorkspace(AWorkspaceID: Integer;
      AName, ADescription: string; AUserID: Integer);
  end;

var
  DMWorkspace: TDMWorkspace;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uDMMain, uAuditLogger;

{$R *.dfm}

{ TDMWorkspace }

procedure TDMWorkspace.LoadWorkspaces(AUserID: Integer);
begin
  qryWorkspaces.Close;
  qryWorkspaces.Connection := DMMain.Instance.conMariaDB;
  qryWorkspaces.SQL.Text :=
    'SELECT w.* ' +
    'FROM   workspaces w ' +
    'JOIN   workspace_members wm ON wm.workspace_id = w.id ' +
    'WHERE  wm.user_id    = :user_id ' +
    '  AND  w.is_deleted  = FALSE ' +
    'ORDER  BY w.created_at DESC';
  qryWorkspaces.ParamByName('user_id').AsInteger := AUserID;
  qryWorkspaces.Open;
end;

function TDMWorkspace.CreateWorkspace(AName, AProgramme: string;
  ACycleYear, AOwnerID: Integer): Integer;
var
  LInsert: TUniQuery;
begin
  Result := 0;
  LInsert := TUniQuery.Create(nil);
  try
    LInsert.Connection := DMMain.Instance.conMariaDB;
    LInsert.SQL.Text :=
      'INSERT INTO workspaces (name, programme, cycle_year, owner_id) ' +
      'VALUES (:name, :programme, :cycle_year, :owner_id)';
    LInsert.ParamByName('name').AsString        := AName;
    LInsert.ParamByName('programme').AsString   := AProgramme;
    LInsert.ParamByName('cycle_year').AsInteger := ACycleYear;
    LInsert.ParamByName('owner_id').AsInteger   := AOwnerID;
    LInsert.ExecSQL;
    Result := DMMain.Instance.conMariaDB.GetLastInsertId;
    // Add owner as workspace member
    LInsert.SQL.Text :=
      'INSERT INTO workspace_members (workspace_id, user_id, role) ' +
      'VALUES (:workspace_id, :user_id, ''owner'')';
    LInsert.ParamByName('workspace_id').AsInteger := Result;
    LInsert.ParamByName('user_id').AsInteger      := AOwnerID;
    LInsert.ExecSQL;
    AuditLog('workspace.create', 0, 'workspace', IntToStr(Result), AName);
  finally
    LInsert.Free;
  end;
end;

procedure TDMWorkspace.SoftDeleteWorkspace(AWorkspaceID, AUserID: Integer);
var
  LUpd: TUniQuery;
begin
  // Soft delete only — never DELETE FROM workspaces
  LUpd := TUniQuery.Create(nil);
  try
    LUpd.Connection := DMMain.Instance.conMariaDB;
    LUpd.SQL.Text :=
      'UPDATE workspaces SET is_deleted = TRUE, updated_at = NOW() ' +
      'WHERE  id = :id';
    LUpd.ParamByName('id').AsInteger := AWorkspaceID;
    LUpd.ExecSQL;
    AuditLog('workspace.delete', 0, 'workspace', IntToStr(AWorkspaceID));
  finally
    LUpd.Free;
  end;
end;

procedure TDMWorkspace.UpdateWorkspace(AWorkspaceID: Integer;
  AName, ADescription: string; AUserID: Integer);
var
  LUpd: TUniQuery;
begin
  LUpd := TUniQuery.Create(nil);
  try
    LUpd.Connection := DMMain.Instance.conMariaDB;
    LUpd.SQL.Text :=
      'UPDATE workspaces ' +
      'SET    name = :name, description = :description, updated_at = NOW() ' +
      'WHERE  id = :id';
    LUpd.ParamByName('name').AsString        := AName;
    LUpd.ParamByName('description').AsString := ADescription;
    LUpd.ParamByName('id').AsInteger         := AWorkspaceID;
    LUpd.ExecSQL;
    AuditLog('workspace.update', 0, 'workspace', IntToStr(AWorkspaceID), AName);
  finally
    LUpd.Free;
  end;
end;

end.
