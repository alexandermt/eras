object ExportForm: TExportForm
  Caption = 'Export Rankings'
  ClientHeight = 400
  ClientWidth = 500
  OnCreate = UniFormCreate
  object pnlOptions: TUniPanel
    Align = alClient
    object rgFormat: TUniRadioGroup
      Caption = 'Export Format'
      Left = 20
      Top = 20
      Width = 200
      Height = 80
    end
    object cgColumns: TUniCheckGroup
      Caption = 'Include Columns'
      Left = 20
      Top = 120
      Width = 440
      Height = 200
    end
  end
  object pnlButtons: TUniPanel
    Align = alBottom
    Height = 50
    object btnPreview: TUniButton
      Caption = 'Preview'
      Left = 20
      Top = 10
      Width = 90
      Height = 30
      OnClick = btnPreviewClick
    end
    object btnDownload: TUniButton
      Caption = 'Download'
      Left = 120
      Top = 10
      Width = 90
      Height = 30
      OnClick = btnDownloadClick
    end
    object btnClose: TUniButton
      Caption = 'Close'
      Left = 380
      Top = 10
      Width = 90
      Height = 30
      OnClick = btnCloseClick
    end
  end
end
