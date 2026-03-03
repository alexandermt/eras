unit uWorkspaceForm;

interface

uses
  SysUtils, Classes, Controls, Forms, DB,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniPanel, uniButton, uniDBGrid, uniEdit, uniComboBox, uniSpinEdit,
  uniToolBar, uniLabel, uniMessageDialog,
  uSessionManager, uConstants;

type
  TWorkspaceForm = class(TUniForm)
    pnlToolbar:       TUniPanel;
    btnNew:           TUniButton;
    btnOpen:          TUniButton;
    btnDelete:        TUniButton;
    grdWorkspaces:    TUniDBGrid;
    pnlNewWorkspace:  TUniPanel;
    lblName:          TUniLabel;
    edtName:          TUniEdit;
    lblProgramme:     TUniLabel;
    cboProgramme:     TUniComboBox;
    lblCycleYear:     TUniLabel;
    spnCycleYear:     TUniSpinEdit;
    btnSaveNew:       TUniButton;
    btnCancelNew:     TUniButton;
  private
    procedure LoadProgrammes;
    procedure ShowNewWorkspacePanel(AVisible: Boolean);
  public
    procedure UniFormCreate(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSaveNewClick(Sender: TObject);
    procedure btnCancelNewClick(Sender: TObject);
  end;

function WorkspaceForm: TWorkspaceForm;

implementation

{$R *.dfm}

uses
  uDMWorkspace, uDMMain, uSnapshotForm;

function WorkspaceForm: TWorkspaceForm;
begin
  Result := TWorkspaceForm(UniApplication.UniMainModule);
end;

procedure TWorkspaceForm.UniFormCreate(Sender: TObject);
var
  LUser: TUserInfo;
begin
  LUser := SessionManager.GetCurrentUser;
  DMWorkspace.LoadWorkspaces(LUser.UserID);
  grdWorkspaces.DataSource := DMWorkspace.dsWorkspaces;
  LoadProgrammes;
  ShowNewWorkspacePanel(False);
end;

procedure TWorkspaceForm.LoadProgrammes;
var
  I: Integer;
begin
  cboProgramme.Items.Clear;
  for I := Low(PROGRAMME_LIST) to High(PROGRAMME_LIST) do
    cboProgramme.Items.Add(PROGRAMME_LIST[I]);
  if cboProgramme.Items.Count > 0 then
    cboProgramme.ItemIndex := 0;
end;

procedure TWorkspaceForm.ShowNewWorkspacePanel(AVisible: Boolean);
begin
  pnlNewWorkspace.Visible := AVisible;
end;

procedure TWorkspaceForm.btnNewClick(Sender: TObject);
begin
  edtName.Text        := '';
  spnCycleYear.Value  := YearOf(Now);
  ShowNewWorkspacePanel(True);
  edtName.SetFocus;
end;

procedure TWorkspaceForm.btnOpenClick(Sender: TObject);
begin
  if DMWorkspace.qryWorkspaces.IsEmpty then Exit;
  UniSession.SendResponse(
    '<script>ERAS.navigateTo("snapshots","' +
    DMWorkspace.qryWorkspaces.FieldByName('id').AsString + '");</script>'
  );
end;

procedure TWorkspaceForm.btnDeleteClick(Sender: TObject);
var
  LUser: TUserInfo;
  LID:   Integer;
begin
  if DMWorkspace.qryWorkspaces.IsEmpty then Exit;
  LID := DMWorkspace.qryWorkspaces.FieldByName('id').AsInteger;
  if UniMessageDlg('Are you sure you want to delete this workspace?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    LUser := SessionManager.GetCurrentUser;
    DMWorkspace.SoftDeleteWorkspace(LID, LUser.UserID);
    DMWorkspace.LoadWorkspaces(LUser.UserID);
  end;
end;

procedure TWorkspaceForm.btnSaveNewClick(Sender: TObject);
var
  LUser:  TUserInfo;
  LNewID: Integer;
begin
  if Trim(edtName.Text) = '' then
  begin
    UniMessageDlg('Please enter a workspace name.', mtWarning, [mbOK], 0);
    edtName.SetFocus;
    Exit;
  end;
  LUser  := SessionManager.GetCurrentUser;
  LNewID := DMWorkspace.CreateWorkspace(
    Trim(edtName.Text),
    cboProgramme.Text,
    Trunc(spnCycleYear.Value),
    LUser.UserID
  );
  ShowNewWorkspacePanel(False);
  DMWorkspace.LoadWorkspaces(LUser.UserID);
end;

procedure TWorkspaceForm.btnCancelNewClick(Sender: TObject);
begin
  ShowNewWorkspacePanel(False);
end;

end.
