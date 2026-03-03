unit uDMRankings;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, MySQLUniProvider;

type
  TDMRankings = class(TDataModule)
    qryRankings:    TUniQuery;
    dsRankings:     TDataSource;
    qryBulkUpdate:  TUniQuery;
  private
    { Private declarations }
  public
    procedure LoadRankings(ASnapshotID: Integer);
    procedure SaveRankingRow(ASnapshotID: Integer; AOracleRef: string;
      ARank: Integer; AScore: Double; AStatus, ANotes: string;
      AUserID: Integer);
    procedure BulkReorder(ASnapshotID: Integer;
      AOrderedRefs: TStringList; AUserID: Integer);
    procedure PrepareExportDataset(ASnapshotID: Integer);
    function  GetRankingCount(ASnapshotID: Integer): Integer;
  end;

var
  DMRankings: TDMRankings;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uDMMain, uDMSnapshot, uAuditLogger;

{$R *.dfm}

{ TDMRankings }

procedure TDMRankings.LoadRankings(ASnapshotID: Integer);
begin
  qryRankings.Close;
  qryRankings.Connection := DMMain.Instance.conMariaDB;
  qryRankings.SQL.Text :=
    'SELECT r.id, ' +
    '       r.snapshot_id, ' +
    '       r.oracle_ref, ' +
    '       r.rank_position, ' +
    '       r.score, ' +
    '       r.status, ' +
    '       r.notes, ' +
    '       r.updated_at, ' +
    '       JSON_VALUE(sa.applicant_data, ''$.surname'')  AS surname, ' +
    '       JSON_VALUE(sa.applicant_data, ''$.forename'') AS forename, ' +
    '       JSON_VALUE(sa.applicant_data, ''$.programme_code'') AS programme ' +
    'FROM   rankings r ' +
    'JOIN   snapshot_applicants sa ' +
    '       ON sa.snapshot_id = r.snapshot_id ' +
    '       AND sa.oracle_ref = r.oracle_ref ' +
    'WHERE  r.snapshot_id = :snapshot_id ' +
    'ORDER  BY r.rank_position, r.oracle_ref';
  qryRankings.ParamByName('snapshot_id').AsInteger := ASnapshotID;
  qryRankings.Open;
end;

procedure TDMRankings.SaveRankingRow(ASnapshotID: Integer; AOracleRef: string;
  ARank: Integer; AScore: Double; AStatus, ANotes: string; AUserID: Integer);
begin
  if DMSnapshot.IsSnapshotFrozen(ASnapshotID) then
    raise Exception.Create('Cannot edit a frozen snapshot');
  qryBulkUpdate.Close;
  qryBulkUpdate.Connection := DMMain.Instance.conMariaDB;
  qryBulkUpdate.SQL.Text :=
    'UPDATE rankings ' +
    'SET    rank_position    = :rank_position, ' +
    '       score            = :score, ' +
    '       status           = :status, ' +
    '       notes            = :notes, ' +
    '       last_updated_by  = :user_id ' +
    'WHERE  snapshot_id = :snapshot_id ' +
    '  AND  oracle_ref  = :oracle_ref';
  qryBulkUpdate.ParamByName('rank_position').AsInteger  := ARank;
  qryBulkUpdate.ParamByName('score').AsFloat            := AScore;
  qryBulkUpdate.ParamByName('status').AsString          := AStatus;
  qryBulkUpdate.ParamByName('notes').AsString           := ANotes;
  qryBulkUpdate.ParamByName('user_id').AsInteger        := AUserID;
  qryBulkUpdate.ParamByName('snapshot_id').AsInteger    := ASnapshotID;
  qryBulkUpdate.ParamByName('oracle_ref').AsString      := AOracleRef;
  qryBulkUpdate.ExecSQL;
  AuditLog('ranking.update', ASnapshotID, 'ranking', AOracleRef,
    Format('rank=%d status=%s', [ARank, AStatus]));
end;

procedure TDMRankings.BulkReorder(ASnapshotID: Integer;
  AOrderedRefs: TStringList; AUserID: Integer);
var
  I: Integer;
  LUpd: TUniQuery;
begin
  if DMSnapshot.IsSnapshotFrozen(ASnapshotID) then
    raise Exception.Create('Cannot reorder a frozen snapshot');
  LUpd := TUniQuery.Create(nil);
  try
    LUpd.Connection := DMMain.Instance.conMariaDB;
    for I := 0 to AOrderedRefs.Count - 1 do
    begin
      LUpd.SQL.Text :=
        'UPDATE rankings SET rank_position = :rank, last_updated_by = :user_id ' +
        'WHERE  snapshot_id = :snapshot_id AND oracle_ref = :oracle_ref';
      LUpd.ParamByName('rank').AsInteger        := I + 1;
      LUpd.ParamByName('user_id').AsInteger     := AUserID;
      LUpd.ParamByName('snapshot_id').AsInteger := ASnapshotID;
      LUpd.ParamByName('oracle_ref').AsString   := AOrderedRefs[I];
      LUpd.ExecSQL;
    end;
    AuditLog('ranking.bulk_reorder', ASnapshotID, 'snapshot', IntToStr(ASnapshotID));
  finally
    LUpd.Free;
  end;
end;

procedure TDMRankings.PrepareExportDataset(ASnapshotID: Integer);
begin
  // Load the rankings dataset ready for FastReport consumption
  LoadRankings(ASnapshotID);
end;

function TDMRankings.GetRankingCount(ASnapshotID: Integer): Integer;
var
  LQry: TUniQuery;
begin
  Result := 0;
  LQry := TUniQuery.Create(nil);
  try
    LQry.Connection := DMMain.Instance.conMariaDB;
    LQry.SQL.Text :=
      'SELECT COUNT(*) AS cnt FROM rankings WHERE snapshot_id = :snapshot_id';
    LQry.ParamByName('snapshot_id').AsInteger := ASnapshotID;
    LQry.Open;
    Result := LQry.FieldByName('cnt').AsInteger;
    LQry.Close;
  finally
    LQry.Free;
  end;
end;

end.
