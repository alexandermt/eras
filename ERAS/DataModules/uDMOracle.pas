unit uDMOracle;

interface

uses
  SysUtils, Classes, DB,
  Uni, UniProvider, OracleUniProvider,
  System.JSON;

type
  TDMOracle = class(TDataModule)
    qryApplicants:      TUniQuery;
    qryApplicantDetail: TUniQuery;
  private
    { Private declarations }
  public
    function GetApplicantsJSON(ACycle: Integer; AProgramme: string;
      ALimit, AOffset: Integer): string;
    function GetApplicantDetailJSON(AOracleRef: string): string;
  end;

var
  DMOracle: TDMOracle;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  uDMMain;

{$R *.dfm}

{ TDMOracle }

function TDMOracle.GetApplicantsJSON(ACycle: Integer; AProgramme: string;
  ALimit, AOffset: Integer): string;
var
  LArr: TJSONArray;
  LObj: TJSONObject;
begin
  qryApplicants.Close;
  qryApplicants.Connection := DMMain.Instance.conOracle;
  qryApplicants.SQL.Text :=
    'SELECT a.applicant_id, ' +
    '       a.forename, ' +
    '       a.surname, ' +
    '       a.email, ' +
    '       a.dob, ' +
    '       p.programme_code, ' +
    '       p.application_status, ' +
    '       p.submitted_date ' +
    'FROM   its_applicants a ' +
    'JOIN   its_programme_choices p ON p.applicant_id = a.applicant_id ' +
    'WHERE  p.cycle_year     = :cycle ' +
    '  AND  p.programme_code = :programme ' +
    'ORDER  BY a.surname, a.forename ' +
    'OFFSET :offset ROWS FETCH NEXT :limit ROWS ONLY';
  qryApplicants.ParamByName('cycle').AsInteger      := ACycle;
  qryApplicants.ParamByName('programme').AsString   := AProgramme;
  qryApplicants.ParamByName('limit').AsInteger      := ALimit;
  qryApplicants.ParamByName('offset').AsInteger     := AOffset;
  qryApplicants.Open;
  try
    LArr := TJSONArray.Create;
    try
      while not qryApplicants.Eof do
      begin
        LObj := TJSONObject.Create;
        LObj.AddPair('applicant_id',      qryApplicants.FieldByName('applicant_id').AsString);
        LObj.AddPair('forename',          qryApplicants.FieldByName('forename').AsString);
        LObj.AddPair('surname',           qryApplicants.FieldByName('surname').AsString);
        LObj.AddPair('email',             qryApplicants.FieldByName('email').AsString);
        LObj.AddPair('dob',               qryApplicants.FieldByName('dob').AsString);
        LObj.AddPair('programme_code',    qryApplicants.FieldByName('programme_code').AsString);
        LObj.AddPair('application_status',qryApplicants.FieldByName('application_status').AsString);
        LObj.AddPair('submitted_date',    qryApplicants.FieldByName('submitted_date').AsString);
        LArr.AddElement(LObj);
        qryApplicants.Next;
      end;
      Result := LArr.ToJSON;
    finally
      LArr.Free;
    end;
  finally
    qryApplicants.Close;
  end;
end;

function TDMOracle.GetApplicantDetailJSON(AOracleRef: string): string;
var
  LObj: TJSONObject;
  I: Integer;
begin
  qryApplicantDetail.Close;
  qryApplicantDetail.Connection := DMMain.Instance.conOracle;
  qryApplicantDetail.SQL.Text :=
    'SELECT a.*, p.* ' +
    'FROM   its_applicants a ' +
    'LEFT JOIN its_programme_choices p ON p.applicant_id = a.applicant_id ' +
    'WHERE  a.applicant_id = :applicant_id';
  qryApplicantDetail.ParamByName('applicant_id').AsString := AOracleRef;
  qryApplicantDetail.Open;
  try
    if qryApplicantDetail.IsEmpty then
    begin
      Result := '{}';
      Exit;
    end;
    LObj := TJSONObject.Create;
    try
      for I := 0 to qryApplicantDetail.FieldCount - 1 do
        LObj.AddPair(
          LowerCase(qryApplicantDetail.Fields[I].FieldName),
          qryApplicantDetail.Fields[I].AsString
        );
      Result := LObj.ToJSON;
    finally
      LObj.Free;
    end;
  finally
    qryApplicantDetail.Close;
  end;
end;

end.
