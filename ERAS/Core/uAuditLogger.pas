unit uAuditLogger;

interface

procedure AuditLog(AAction: string; ASnapshotID: Integer = 0;
  AEntityType: string = ''; AEntityID: string = ''; APayload: string = '');

implementation

uses
  uSessionManager, uDMAudit;

procedure AuditLog(AAction: string; ASnapshotID: Integer = 0;
  AEntityType: string = ''; AEntityID: string = ''; APayload: string = '');
var
  LUser: TUserInfo;
begin
  LUser := SessionManager.GetCurrentUser;
  DMAudit.Log(LUser.UserID, AAction, ASnapshotID, AEntityType, AEntityID, APayload);
end;

end.
