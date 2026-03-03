unit uLoginForm;

interface

uses
  SysUtils, Classes, Controls, Forms,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniEdit, uniButton, uniLabel, uniPanel, uniMessageDialog,
  uSessionManager, uConstants;

type
  TLoginForm = class(TUniForm)
    pnlCenter:    TUniPanel;
    lblTitle:     TUniLabel;
    lblUsername:  TUniLabel;
    edtUsername:  TUniEdit;
    lblPassword:  TUniLabel;
    edtPassword:  TUniEdit;
    btnLogin:     TUniButton;
  private
    procedure DoLogin;
  public
    procedure btnLoginClick(Sender: TObject);
  end;

function LoginForm: TLoginForm;

implementation

{$R *.dfm}

uses
  uDMMain, uMainForm, uJSONHelper;

function LoginForm: TLoginForm;
begin
  Result := TLoginForm(UniApplication.UniMainModule);
end;

procedure TLoginForm.btnLoginClick(Sender: TObject);
begin
  DoLogin;
end;

procedure TLoginForm.DoLogin;
var
  LUser:     TUserInfo;
  LUsername: string;
  LPassword: string;
begin
  LUsername := Trim(edtUsername.Text);
  LPassword := edtPassword.Text;
  if LUsername = '' then
  begin
    UniMessageDlg('Please enter your username.', mtWarning, [mbOK], 0);
    edtUsername.SetFocus;
    Exit;
  end;
  LUser := TDMMain.Instance.AuthenticateLDAP(LUsername, LPassword);
  if LUser.Username <> '' then
  begin
    LUser.LoginTime := Now;
    SessionManager.SetCurrentUser(LUser);
    UniSession.SendResponse('<script>window.location.href="/";</script>');
  end
  else
    UniMessageDlg('Invalid credentials. Please try again.', mtError, [mbOK], 0);
end;

end.
