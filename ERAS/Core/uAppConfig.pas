unit uAppConfig;

interface

uses
  SysUtils, IniFiles;

type
  TAppConfig = class
  private
    class var FInstance: TAppConfig;
    FIniFile: TIniFile;
    // Database
    FMariaDBHost:     string;
    FMariaDBPort:     Integer;
    FMariaDBDatabase: string;
    FMariaDBUser:     string;
    FMariaDBPassword: string;
    // Oracle
    FOracleTNS:       string;
    FOracleUser:      string;
    FOraclePassword:  string;
    FOracleDirect:    Boolean;
    // LDAP
    FLDAPHost:        string;
    FLDAPDomain:      string;
    FLDAPBaseDN:      string;
    // Application
    FSessionTimeoutMins: Integer;
    FSnapshotMode:    Boolean;
    FReportsPath:     string;
    FPythonPath:      string;
    FLogPath:         string;
  public
    class function Instance: TAppConfig;
    class destructor Destroy;
    procedure Load;
    // Database
    property MariaDBHost:     string  read FMariaDBHost;
    property MariaDBPort:     Integer read FMariaDBPort;
    property MariaDBDatabase: string  read FMariaDBDatabase;
    property MariaDBUser:     string  read FMariaDBUser;
    property MariaDBPassword: string  read FMariaDBPassword;
    // Oracle
    property OracleTNS:       string  read FOracleTNS;
    property OracleUser:      string  read FOracleUser;
    property OraclePassword:  string  read FOraclePassword;
    property OracleDirect:    Boolean read FOracleDirect;
    // LDAP
    property LDAPHost:        string  read FLDAPHost;
    property LDAPDomain:      string  read FLDAPDomain;
    property LDAPBaseDN:      string  read FLDAPBaseDN;
    // Application
    property SessionTimeoutMins: Integer read FSessionTimeoutMins;
    property SnapshotMode:    Boolean read FSnapshotMode;
    property ReportsPath:     string  read FReportsPath;
    property PythonPath:      string  read FPythonPath;
    property LogPath:         string  read FLogPath;
  end;

implementation

{ TAppConfig }

class function TAppConfig.Instance: TAppConfig;
begin
  if FInstance = nil then
  begin
    FInstance := TAppConfig.Create;
    FInstance.Load;
  end;
  Result := FInstance;
end;

class destructor TAppConfig.Destroy;
begin
  FreeAndNil(FInstance);
end;

procedure TAppConfig.Load;
var
  LPath: string;
begin
  LPath := ExtractFilePath(ParamStr(0)) + 'config.ini';
  if not FileExists(LPath) then
    raise Exception.CreateFmt('Configuration file not found: %s', [LPath]);
  FIniFile := TIniFile.Create(LPath);
  try
    FMariaDBHost     := FIniFile.ReadString ('Database',    'MariaDBHost',     'localhost');
    FMariaDBPort     := FIniFile.ReadInteger('Database',    'MariaDBPort',     3306);
    FMariaDBDatabase := FIniFile.ReadString ('Database',    'MariaDBDatabase', 'eras');
    FMariaDBUser     := FIniFile.ReadString ('Database',    'MariaDBUser',     '');
    FMariaDBPassword := FIniFile.ReadString ('Database',    'MariaDBPassword', '');
    FOracleTNS       := FIniFile.ReadString ('Oracle',      'OracleTNS',       '');
    FOracleUser      := FIniFile.ReadString ('Oracle',      'OracleUser',      '');
    FOraclePassword  := FIniFile.ReadString ('Oracle',      'OraclePassword',  '');
    FOracleDirect    := FIniFile.ReadBool   ('Oracle',      'OracleDirect',    True);
    FLDAPHost        := FIniFile.ReadString ('LDAP',        'LDAPHost',        '');
    FLDAPDomain      := FIniFile.ReadString ('LDAP',        'LDAPDomain',      '');
    FLDAPBaseDN      := FIniFile.ReadString ('LDAP',        'LDAPBaseDN',      '');
    FSessionTimeoutMins := FIniFile.ReadInteger('Application', 'SessionTimeout', 480);
    FSnapshotMode    := FIniFile.ReadBool   ('Application', 'SnapshotMode',    True);
    FReportsPath     := FIniFile.ReadString ('Application', 'ReportsPath',     '.\Reports\');
    FPythonPath      := FIniFile.ReadString ('Application', 'PythonPath',      '.\python_env\');
    FLogPath         := FIniFile.ReadString ('Application', 'LogPath',         '.\logs\');
  finally
    FreeAndNil(FIniFile);
  end;
end;

end.
