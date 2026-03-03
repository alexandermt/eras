object MainForm: TMainForm
  Caption = 'ERAS - Enterprise Ranking & Admissions System'
  ClientHeight = 700
  ClientWidth = 1200
  OnCreate = UniFormCreate
  object pnlTop: TUniPanel
    Align = alTop
    Height = 50
    object lblAppTitle: TUniLabel
      Caption = 'ERAS - Enterprise Ranking && Admissions System'
      Left = 10
      Top = 14
      StyleName = 'app-title'
    end
    object lblUsername: TUniLabel
      Caption = ''
      Left = 900
      Top = 14
    end
    object btnLogout: TUniButton
      Caption = 'Logout'
      Left = 1100
      Top = 10
      Width = 80
      Height = 30
      OnClick = btnLogoutClick
    end
  end
  object pnlSidebar: TUniPanel
    Align = alLeft
    Width = 220
    Top = 50
    Height = 650
  end
  object pnlContent: TUniPanel
    Align = alClient
    Top = 50
    object pgcMain: TUniPageControl
      Align = alClient
      object tsWorkspaces: TUniTabSheet
        Caption = 'Workspaces'
      end
      object tsSnapshot: TUniTabSheet
        Caption = 'Snapshots'
      end
      object tsRankings: TUniTabSheet
        Caption = 'Rankings'
      end
      object tsExport: TUniTabSheet
        Caption = 'Export'
      end
    end
  end
end
