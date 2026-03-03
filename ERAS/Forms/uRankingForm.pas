unit uRankingForm;

interface

uses
  SysUtils, Classes, Controls, Forms, DB,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniPanel, uniButton, uniDBGrid, uniLabel, uniStatusBar,
  uniMessageDialog,
  uSessionManager, uConstants;

type
  TRankingForm = class(TUniForm)
    pnlToolbar:   TUniPanel;
    btnSave:      TUniButton;
    btnExport:    TUniButton;
    btnRefresh:   TUniButton;
    grdRankings:  TUniDBGrid;
    stbStatus:    TUniStatusBar;
  private
    FSnapshotID: Integer;
    FFrozen:     Boolean;
    procedure UpdateFrozenState;
    procedure UpdateStatusBar;
  public
    procedure LoadForSnapshot(ASnapshotID: Integer);
    procedure UniFormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  end;

function RankingForm: TRankingForm;

implementation

{$R *.dfm}

uses
  uDMRankings, uDMSnapshot, uExportForm;

function RankingForm: TRankingForm;
begin
  Result := TRankingForm(UniApplication.UniMainModule);
end;

procedure TRankingForm.UniFormCreate(Sender: TObject);
begin
  FSnapshotID := 0;
  FFrozen     := False;
end;

procedure TRankingForm.LoadForSnapshot(ASnapshotID: Integer);
begin
  FSnapshotID := ASnapshotID;
  FFrozen     := DMSnapshot.IsSnapshotFrozen(ASnapshotID);
  DMRankings.LoadRankings(FSnapshotID);
  grdRankings.DataSource := DMRankings.dsRankings;
  UpdateFrozenState;
  UpdateStatusBar;
end;

procedure TRankingForm.UpdateFrozenState;
begin
  grdRankings.ReadOnly := FFrozen;
  btnSave.Enabled      := not FFrozen;
  if FFrozen then
    stbStatus.Panels[0].Text := 'FROZEN'
  else
    stbStatus.Panels[0].Text := 'Active';
end;

procedure TRankingForm.UpdateStatusBar;
begin
  stbStatus.Panels[1].Text :=
    'Records: ' + IntToStr(DMRankings.GetRankingCount(FSnapshotID));
end;

procedure TRankingForm.btnSaveClick(Sender: TObject);
var
  LUser: TUserInfo;
begin
  if FFrozen then
  begin
    UniMessageDlg('This snapshot is frozen and cannot be edited.', mtWarning, [mbOK], 0);
    Exit;
  end;
  LUser := SessionManager.GetCurrentUser;
  try
    DMRankings.qryRankings.First;
    while not DMRankings.qryRankings.Eof do
    begin
      DMRankings.SaveRankingRow(
        FSnapshotID,
        DMRankings.qryRankings.FieldByName('oracle_ref').AsString,
        DMRankings.qryRankings.FieldByName('rank_position').AsInteger,
        DMRankings.qryRankings.FieldByName('score').AsFloat,
        DMRankings.qryRankings.FieldByName('status').AsString,
        DMRankings.qryRankings.FieldByName('notes').AsString,
        LUser.UserID
      );
      DMRankings.qryRankings.Next;
    end;
    UniMessageDlg('Rankings saved successfully.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      UniMessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRankingForm.btnExportClick(Sender: TObject);
begin
  ExportForm.LoadForSnapshot(FSnapshotID);
  ExportForm.ShowModal;
end;

procedure TRankingForm.btnRefreshClick(Sender: TObject);
begin
  if FSnapshotID > 0 then
    LoadForSnapshot(FSnapshotID);
end;

end.
