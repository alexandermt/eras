unit uSnapshotForm;

interface

uses
  SysUtils, Classes, Controls, Forms, DB,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniPanel, uniButton, uniDBGrid, uniEdit, uniLabel,
  uniMessageDialog,
  uSessionManager;

type
  TSnapshotForm = class(TUniForm)
    pnlToolbar:    TUniPanel;
    btnNewSnap:    TUniButton;
    btnOpenRank:   TUniButton;
    btnFreeze:     TUniButton;
    grdSnapshots:  TUniDBGrid;
    pnlNewSnap:    TUniPanel;
    lblSnapLabel:  TUniLabel;
    edtSnapLabel:  TUniEdit;
    btnSaveSnap:   TUniButton;
    btnCancelSnap: TUniButton;
  private
    FWorkspaceID: Integer;
  public
    procedure LoadForWorkspace(AWorkspaceID: Integer);
    procedure UniFormCreate(Sender: TObject);
    procedure btnNewSnapClick(Sender: TObject);
    procedure btnOpenRankClick(Sender: TObject);
    procedure btnFreezeClick(Sender: TObject);
    procedure btnSaveSnapClick(Sender: TObject);
    procedure btnCancelSnapClick(Sender: TObject);
  end;

function SnapshotForm: TSnapshotForm;

implementation

{$R *.dfm}

uses
  uDMSnapshot, uRankingForm;

function SnapshotForm: TSnapshotForm;
begin
  Result := TSnapshotForm(UniApplication.UniMainModule);
end;

procedure TSnapshotForm.UniFormCreate(Sender: TObject);
begin
  pnlNewSnap.Visible := False;
end;

procedure TSnapshotForm.LoadForWorkspace(AWorkspaceID: Integer);
begin
  FWorkspaceID := AWorkspaceID;
  DMSnapshot.LoadSnapshots(FWorkspaceID);
  grdSnapshots.DataSource := DMSnapshot.dsSnapshots;
end;

procedure TSnapshotForm.btnNewSnapClick(Sender: TObject);
begin
  edtSnapLabel.Text  := '';
  pnlNewSnap.Visible := True;
  edtSnapLabel.SetFocus;
end;

procedure TSnapshotForm.btnOpenRankClick(Sender: TObject);
begin
  if DMSnapshot.qrySnapshots.IsEmpty then Exit;
  RankingForm.LoadForSnapshot(
    DMSnapshot.qrySnapshots.FieldByName('id').AsInteger
  );
end;

procedure TSnapshotForm.btnFreezeClick(Sender: TObject);
var
  LUser: TUserInfo;
  LID:   Integer;
begin
  if DMSnapshot.qrySnapshots.IsEmpty then Exit;
  LID := DMSnapshot.qrySnapshots.FieldByName('id').AsInteger;
  if UniMessageDlg(
    'Freeze this snapshot? Rankings will become read-only.',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    LUser := SessionManager.GetCurrentUser;
    try
      DMSnapshot.FreezeSnapshot(LID, LUser.UserID);
      DMSnapshot.LoadSnapshots(FWorkspaceID);
    except
      on E: Exception do
        UniMessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TSnapshotForm.btnSaveSnapClick(Sender: TObject);
var
  LUser:  TUserInfo;
  LLabel: string;
begin
  LLabel := Trim(edtSnapLabel.Text);
  if LLabel = '' then
  begin
    UniMessageDlg('Please enter a snapshot label.', mtWarning, [mbOK], 0);
    edtSnapLabel.SetFocus;
    Exit;
  end;
  LUser := SessionManager.GetCurrentUser;
  try
    DMSnapshot.CreateSnapshot(FWorkspaceID, LLabel, LUser.UserID);
    pnlNewSnap.Visible := False;
    DMSnapshot.LoadSnapshots(FWorkspaceID);
  except
    on E: Exception do
      UniMessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TSnapshotForm.btnCancelSnapClick(Sender: TObject);
begin
  pnlNewSnap.Visible := False;
end;

end.
