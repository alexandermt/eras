object RankingForm: TRankingForm
  Caption = 'Rankings'
  ClientHeight = 700
  ClientWidth = 1100
  OnCreate = UniFormCreate
  object pnlToolbar: TUniPanel
    Align = alTop
    Height = 40
    object btnSave: TUniButton
      Caption = 'Save Changes'
      Left = 8
      Top = 6
      Width = 110
      Height = 28
      OnClick = btnSaveClick
    end
    object btnExport: TUniButton
      Caption = 'Export'
      Left = 126
      Top = 6
      Width = 80
      Height = 28
      OnClick = btnExportClick
    end
    object btnRefresh: TUniButton
      Caption = 'Refresh'
      Left = 214
      Top = 6
      Width = 80
      Height = 28
      OnClick = btnRefreshClick
    end
  end
  object grdRankings: TUniDBGrid
    Align = alClient
    Top = 40
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs]
    Columns = <
      item
        FieldName = 'rank_position'
        Title.Caption = 'Rank'
        Width = 60
        ReadOnly = False
      end
      item
        FieldName = 'oracle_ref'
        Title.Caption = 'Oracle Ref'
        Width = 100
        ReadOnly = True
      end
      item
        FieldName = 'surname'
        Title.Caption = 'Surname'
        Width = 120
        ReadOnly = True
      end
      item
        FieldName = 'forename'
        Title.Caption = 'Forename'
        Width = 120
        ReadOnly = True
      end
      item
        FieldName = 'programme'
        Title.Caption = 'Programme'
        Width = 100
        ReadOnly = True
      end
      item
        FieldName = 'score'
        Title.Caption = 'Score'
        Width = 80
        ReadOnly = False
      end
      item
        FieldName = 'status'
        Title.Caption = 'Status'
        Width = 100
        ReadOnly = False
      end
      item
        FieldName = 'notes'
        Title.Caption = 'Notes'
        Width = 300
        ReadOnly = False
      end>
  end
  object stbStatus: TUniStatusBar
    Align = alBottom
    Panels = <
      item
        Width = 100
        Text = ''
      end
      item
        Width = 150
        Text = ''
      end>
  end
end
