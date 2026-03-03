unit uDMMain;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, MySQLUniProvider, OracleUniProvider,
  PythonEngine, VarPyth,
  uAppConfig, uSessionManager, uConstants;

type
  TDMMain = class(TDataModule)
    conMariaDB:        TUniConnection;
    conOracle:         TUniConnection;
    PythonEngine1:     TPythonEngine;
    PythonDelphiVar1:  TPythonDelphiVar;
  private
    class var FInstance: TDMMain;
    procedure SetupMariaDB;
    procedure SetupOracle;
    procedure SetupPython;
  public
    class function  Instance: TDMMain;
    procedure Connect;
    function  AuthenticateLDAP(AUsername, APassword: string): TUserInfo;
    procedure EnsureOracleReadOnly;
  end;

var
  DMMain: TDMMain;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uJSONHelper;

{$R *.dfm}

{ TDMMain }

class function TDMMain.Instance: TDMMain;
begin
  if FInstance = nil then
    FInstance := TDMMain.Create(nil);
  Result := FInstance;
end;

procedure TDMMain.Connect;
begin
  SetupMariaDB;
  SetupOracle;
  SetupPython;
end;

procedure TDMMain.SetupMariaDB;
var
  LCfg: TAppConfig;
begin
  LCfg := TAppConfig.Instance;
  conMariaDB.ProviderName := 'MySQL';
  conMariaDB.Server       := LCfg.MariaDBHost;
  conMariaDB.Port         := LCfg.MariaDBPort;
  conMariaDB.Database     := LCfg.MariaDBDatabase;
  conMariaDB.Username     := LCfg.MariaDBUser;
  conMariaDB.Password     := LCfg.MariaDBPassword;
  conMariaDB.Connect;
end;

procedure TDMMain.SetupOracle;
var
  LCfg: TAppConfig;
begin
  LCfg := TAppConfig.Instance;
  conOracle.ProviderName := 'Oracle';
  conOracle.Server       := LCfg.OracleTNS;
  conOracle.Username     := LCfg.OracleUser;
  conOracle.Password     := LCfg.OraclePassword;
  conOracle.SpecificOptions.Values['Direct'] := BoolToStr(LCfg.OracleDirect, True);
  conOracle.Connect;
  EnsureOracleReadOnly;
end;

procedure TDMMain.SetupPython;
var
  LCfg: TAppConfig;
begin
  LCfg := TAppConfig.Instance;
  PythonEngine1.DllPath    := LCfg.PythonPath;
  PythonEngine1.AutoLoad   := False;
  PythonEngine1.LoadDll;
end;

procedure TDMMain.EnsureOracleReadOnly;
var
  LQry: TUniQuery;
begin
  // Enforce read-only access on Oracle connection
  LQry := TUniQuery.Create(nil);
  try
    LQry.Connection := conOracle;
    LQry.SQL.Text   := 'ALTER SESSION SET TRANSACTION READ ONLY';
    try
      LQry.ExecSQL;
    except
      // Ignore if already in a read-only transaction context
    end;
  finally
    LQry.Free;
  end;
end;

function TDMMain.AuthenticateLDAP(AUsername, APassword: string): TUserInfo;
var
  LCfg:      TAppConfig;
  LScript:   string;
  LResult:   string;
  LScriptPath: string;
begin
  Result.Username := '';
  Result.UserID   := 0;
  LCfg := TAppConfig.Instance;
  LScriptPath := LCfg.PythonPath + 'ldap_auth.py';
  LScript :=
    'import sys, json' + sLineBreak +
    'sys.path.insert(0, r"' + StringReplace(LCfg.PythonPath, '\', '\\', [rfReplaceAll]) + '")' + sLineBreak +
    'from ldap_auth import authenticate' + sLineBreak +
    'result = authenticate(' +
      '"' + StringReplace(AUsername, '"', '\"', [rfReplaceAll]) + '", ' +
      '"' + StringReplace(APassword, '"', '\"', [rfReplaceAll]) + '", ' +
      '"' + LCfg.LDAPHost + '", ' +
      '"' + LCfg.LDAPDomain + '", ' +
      '"' + LCfg.LDAPBaseDN + '")' + sLineBreak +
    'delphi_var.Value = result';
  PythonDelphiVar1.AsString := '';
  PythonEngine1.ExecString(LScript);
  LResult := PythonDelphiVar1.AsString;
  if LResult <> '' then
    Result := ParseUserInfo(LResult);
end;

end.
