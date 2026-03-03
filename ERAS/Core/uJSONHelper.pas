unit uJSONHelper;

interface

uses
  SysUtils, System.JSON, uSessionManager, uConstants;

function JSONGetString(AJSON: TJSONObject; AKey: string): string;
function JSONGetInt(AJSON: TJSONObject; AKey: string): Integer;
function JSONGetFloat(AJSON: TJSONObject; AKey: string): Double;
function ParseUserInfo(AJSON: string): TUserInfo;

implementation

function JSONGetString(AJSON: TJSONObject; AKey: string): string;
var
  LVal: TJSONValue;
begin
  Result := '';
  if AJSON = nil then Exit;
  LVal := AJSON.GetValue(AKey);
  if LVal <> nil then
    Result := LVal.Value;
end;

function JSONGetInt(AJSON: TJSONObject; AKey: string): Integer;
var
  LVal: TJSONValue;
begin
  Result := 0;
  if AJSON = nil then Exit;
  LVal := AJSON.GetValue(AKey);
  if LVal <> nil then
    Result := StrToIntDef(LVal.Value, 0);
end;

function JSONGetFloat(AJSON: TJSONObject; AKey: string): Double;
var
  LVal: TJSONValue;
begin
  Result := 0.0;
  if AJSON = nil then Exit;
  LVal := AJSON.GetValue(AKey);
  if LVal <> nil then
    Result := StrToFloatDef(LVal.Value, 0.0);
end;

function ParseUserInfo(AJSON: string): TUserInfo;
var
  LObj: TJSONObject;
begin
  Result.Username    := '';
  Result.DisplayName := '';
  Result.Email       := '';
  Result.Department  := '';
  Result.IsAdmin     := False;
  Result.UserID      := 0;
  Result.LoginTime   := 0;
  if AJSON = '' then Exit;
  LObj := TJSONObject.ParseJSONValue(AJSON) as TJSONObject;
  if LObj = nil then Exit;
  try
    Result.Username    := JSONGetString(LObj, 'username');
    Result.DisplayName := JSONGetString(LObj, 'display_name');
    Result.Email       := JSONGetString(LObj, 'email');
    Result.Department  := JSONGetString(LObj, 'department');
    Result.IsAdmin     := SameText(JSONGetString(LObj, 'is_admin'), 'true');
    Result.UserID      := JSONGetInt(LObj, 'user_id');
    Result.LoginTime   := Now;
  finally
    LObj.Free;
  end;
end;

end.
