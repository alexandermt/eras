unit uSessionManager;

interface

uses
  SysUtils, uniGUIApplication;

type
  TUserInfo = record
    Username:    string;
    DisplayName: string;
    Email:       string;
    Department:  string;
    IsAdmin:     Boolean;
    UserID:      Integer;
    LoginTime:   TDateTime;
  end;

  TSessionManager = class
  public
    procedure SetCurrentUser(AInfo: TUserInfo);
    function  GetCurrentUser: TUserInfo;
    function  IsAuthenticated: Boolean;
    procedure ClearSession;
  end;

function SessionManager: TSessionManager;

implementation

uses
  uniGUITypes, uniGUIVars;

const
  SESSION_KEY_USERNAME    = 'session.username';
  SESSION_KEY_DISPLAYNAME = 'session.display_name';
  SESSION_KEY_EMAIL       = 'session.email';
  SESSION_KEY_DEPARTMENT  = 'session.department';
  SESSION_KEY_ISADMIN     = 'session.is_admin';
  SESSION_KEY_USERID      = 'session.user_id';
  SESSION_KEY_LOGINTIME   = 'session.login_time';

var
  FSessionManager: TSessionManager;

function SessionManager: TSessionManager;
begin
  if FSessionManager = nil then
    FSessionManager := TSessionManager.Create;
  Result := FSessionManager;
end;

{ TSessionManager }

procedure TSessionManager.SetCurrentUser(AInfo: TUserInfo);
begin
  UniApplication.UniSession.Variables['session.username']    := AInfo.Username;
  UniApplication.UniSession.Variables['session.display_name']:= AInfo.DisplayName;
  UniApplication.UniSession.Variables['session.email']       := AInfo.Email;
  UniApplication.UniSession.Variables['session.department']  := AInfo.Department;
  UniApplication.UniSession.Variables['session.is_admin']    := BoolToStr(AInfo.IsAdmin, True);
  UniApplication.UniSession.Variables['session.user_id']     := IntToStr(AInfo.UserID);
  UniApplication.UniSession.Variables['session.login_time']  := FloatToStr(AInfo.LoginTime);
end;

function TSessionManager.GetCurrentUser: TUserInfo;
var
  LAdminStr: string;
begin
  Result.Username    := UniApplication.UniSession.Variables['session.username'];
  Result.DisplayName := UniApplication.UniSession.Variables['session.display_name'];
  Result.Email       := UniApplication.UniSession.Variables['session.email'];
  Result.Department  := UniApplication.UniSession.Variables['session.department'];
  LAdminStr          := UniApplication.UniSession.Variables['session.is_admin'];
  Result.IsAdmin     := SameText(LAdminStr, 'True');
  Result.UserID      := StrToIntDef(UniApplication.UniSession.Variables['session.user_id'], 0);
  Result.LoginTime   := StrToFloatDef(UniApplication.UniSession.Variables['session.login_time'], 0);
end;

function TSessionManager.IsAuthenticated: Boolean;
begin
  Result := UniApplication.UniSession.Variables['session.username'] <> '';
end;

procedure TSessionManager.ClearSession;
begin
  UniApplication.UniSession.Variables['session.username']    := '';
  UniApplication.UniSession.Variables['session.display_name']:= '';
  UniApplication.UniSession.Variables['session.email']       := '';
  UniApplication.UniSession.Variables['session.department']  := '';
  UniApplication.UniSession.Variables['session.is_admin']    := '';
  UniApplication.UniSession.Variables['session.user_id']     := '';
  UniApplication.UniSession.Variables['session.login_time']  := '';
end;

initialization
  FSessionManager := nil;

finalization
  FreeAndNil(FSessionManager);

end.
