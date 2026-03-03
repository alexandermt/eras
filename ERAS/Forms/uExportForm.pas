unit uExportForm;

interface

uses
  SysUtils, Classes, Controls, Forms,
  uniGUIForm, uniGUIBaseClasses, uniGUIClasses,
  uniPanel, uniButton, uniLabel, uniRadioGroup, uniCheckGroup,
  uniMessageDialog,
  uSessionManager, uAppConfig;

type
  TExportForm = class(TUniForm)
    pnlOptions:    TUniPanel;
    rgFormat:      TUniRadioGroup;
    cgColumns:     TUniCheckGroup;
    pnlButtons:    TUniPanel;
    btnPreview:    TUniButton;
    btnDownload:   TUniButton;
    btnClose:      TUniButton;
  private
    FSnapshotID: Integer;
    function  GetSelectedFormat: string;
    function  GenerateExportFile: string;
  public
    procedure LoadForSnapshot(ASnapshotID: Integer);
    procedure UniFormCreate(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnDownloadClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  end;

function ExportForm: TExportForm;

implementation

{$R *.dfm}

uses
  frxClass, frxExportXLSX, frxExportPDF,
  uDMRankings, uAuditLogger;

function ExportForm: TExportForm;
begin
  Result := TExportForm(UniApplication.UniMainModule);
end;

procedure TExportForm.UniFormCreate(Sender: TObject);
begin
  FSnapshotID := 0;
  // Format options
  rgFormat.Items.Clear;
  rgFormat.Items.Add('Excel XLSX');
  rgFormat.Items.Add('PDF');
  rgFormat.ItemIndex := 0;
  // Column options — match FastReport export columns specification
  cgColumns.Items.Clear;
  cgColumns.Items.Add('Rank');
  cgColumns.Items.Add('Oracle Ref');
  cgColumns.Items.Add('Surname');
  cgColumns.Items.Add('Forename');
  cgColumns.Items.Add('Programme');
  cgColumns.Items.Add('Score');
  cgColumns.Items.Add('Status');
  cgColumns.Items.Add('Notes');
  // Check all by default
  cgColumns.CheckAll;
end;

procedure TExportForm.LoadForSnapshot(ASnapshotID: Integer);
begin
  FSnapshotID := ASnapshotID;
  DMRankings.PrepareExportDataset(FSnapshotID);
end;

function TExportForm.GetSelectedFormat: string;
begin
  if rgFormat.ItemIndex = 0 then
    Result := 'xlsx'
  else
    Result := 'pdf';
end;

function TExportForm.GenerateExportFile: string;
var
  LReport:      TfrxReport;
  LExportXLSX:  TfrxXLSXExport;
  LExportPDF:   TfrxPDFExport;
  LOutputFile:  string;
  LFormat:      string;
  LReportsPath: string;
begin
  LFormat      := GetSelectedFormat;
  LReportsPath := TAppConfig.Instance.ReportsPath;
  LOutputFile  := ExtractFilePath(ParamStr(0)) + 'temp_export_' +
    FormatDateTime('yyyymmddhhnnss', Now) + '.' + LFormat;
  LReport := TfrxReport.Create(nil);
  try
    LReport.LoadFromFile(LReportsPath + 'RankingList.fr3');
    LReport.GetDataSet('Rankings').SetDataSet(DMRankings.qryRankings);
    if LFormat = 'xlsx' then
    begin
      LExportXLSX := TfrxXLSXExport.Create(nil);
      try
        LExportXLSX.FileName := LOutputFile;
        LReport.Export(LExportXLSX);
      finally
        LExportXLSX.Free;
      end;
    end
    else
    begin
      LExportPDF := TfrxPDFExport.Create(nil);
      try
        LExportPDF.FileName := LOutputFile;
        LReport.Export(LExportPDF);
      finally
        LExportPDF.Free;
      end;
    end;
    Result := LOutputFile;
  finally
    LReport.Free;
  end;
end;

procedure TExportForm.btnPreviewClick(Sender: TObject);
var
  LReport:      TfrxReport;
  LReportsPath: string;
begin
  if FSnapshotID = 0 then Exit;
  LReportsPath := TAppConfig.Instance.ReportsPath;
  LReport := TfrxReport.Create(nil);
  try
    LReport.LoadFromFile(LReportsPath + 'RankingList.fr3');
    LReport.GetDataSet('Rankings').SetDataSet(DMRankings.qryRankings);
    LReport.ShowReport(True);
  finally
    LReport.Free;
  end;
end;

procedure TExportForm.btnDownloadClick(Sender: TObject);
var
  LFile: string;
  LUser: TUserInfo;
begin
  if FSnapshotID = 0 then Exit;
  try
    LFile := GenerateExportFile;
    AuditLog('export.' + GetSelectedFormat, FSnapshotID,
      'snapshot', IntToStr(FSnapshotID));
    UniSession.SendFile(LFile);
  except
    on E: Exception do
      UniMessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TExportForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
