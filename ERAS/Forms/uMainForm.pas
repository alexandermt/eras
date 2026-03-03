unit uMainForm;

interface

uses
  SysUtils, Classes, Controls, Forms,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniPanel, uniLabel, uniButton, uniPageControl,
  uSessionManager, uConstants;

type
  TMainForm = class(TUniForm)
    pnlTop:          TUniPanel;
    lblAppTitle:     TUniLabel;
    lblUsername:     TUniLabel;
    btnLogout:       TUniButton;
    pnlSidebar:      TUniPanel;
    pnlContent:      TUniPanel;
    pgcMain:         TUniPageControl;
    tsWorkspaces:    TUniTabSheet;
    tsSnapshot:      TUniTabSheet;
    tsRankings:      TUniTabSheet;
    tsExport:        TUniTabSheet;
  private
    procedure CheckAuthentication;
  public
    procedure UniFormCreate(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uLoginForm;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniApplication.UniMainModule);
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
var
  LUser: TUserInfo;
begin
  CheckAuthentication;
  LUser := SessionManager.GetCurrentUser;
  lblUsername.Caption := LUser.DisplayName;
end;

procedure TMainForm.CheckAuthentication;
begin
  if not SessionManager.IsAuthenticated then
    UniSession.SendResponse('<script>window.location.href="/login";</script>');
end;

procedure TMainForm.btnLogoutClick(Sender: TObject);
begin
  SessionManager.ClearSession;
  UniSession.SendResponse('<script>window.location.href="/login";</script>');
end;

end.
