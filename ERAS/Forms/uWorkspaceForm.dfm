object WorkspaceForm: TWorkspaceForm
  Caption = 'Workspaces'
  ClientHeight = 600
  ClientWidth = 900
  OnCreate = UniFormCreate
  object pnlToolbar: TUniPanel
    Align = alTop
    Height = 40
    object btnNew: TUniButton
      Caption = 'New Workspace'
      Left = 8
      Top = 6
      Width = 120
      Height = 28
      OnClick = btnNewClick
    end
    object btnOpen: TUniButton
      Caption = 'Open'
      Left = 136
      Top = 6
      Width = 80
      Height = 28
      OnClick = btnOpenClick
    end
    object btnDelete: TUniButton
      Caption = 'Delete'
      Left = 224
      Top = 6
      Width = 80
      Height = 28
      OnClick = btnDeleteClick
    end
  end
  object grdWorkspaces: TUniDBGrid
    Align = alClient
    Top = 40
    Columns = <
      item
        FieldName = 'name'
        Title.Caption = 'Name'
        Width = 200
      end
      item
        FieldName = 'programme'
        Title.Caption = 'Programme'
        Width = 100
      end
      item
        FieldName = 'cycle_year'
        Title.Caption = 'Cycle Year'
        Width = 80
      end
      item
        FieldName = 'created_at'
        Title.Caption = 'Created'
        Width = 150
      end>
  end
  object pnlNewWorkspace: TUniPanel
    Align = alBottom
    Height = 180
    Visible = False
    object lblName: TUniLabel
      Caption = 'Name:'
      Left = 20
      Top = 20
    end
    object edtName: TUniEdit
      Left = 20
      Top = 40
      Width = 300
    end
    object lblProgramme: TUniLabel
      Caption = 'Programme:'
      Left = 340
      Top = 20
    end
    object cboProgramme: TUniComboBox
      Left = 340
      Top = 40
      Width = 150
    end
    object lblCycleYear: TUniLabel
      Caption = 'Cycle Year:'
      Left = 510
      Top = 20
    end
    object spnCycleYear: TUniSpinEdit
      Left = 510
      Top = 40
      Width = 100
      MinValue = 2000
      MaxValue = 2099
    end
    object btnSaveNew: TUniButton
      Caption = 'Save'
      Left = 20
      Top = 130
      Width = 80
      Height = 30
      OnClick = btnSaveNewClick
    end
    object btnCancelNew: TUniButton
      Caption = 'Cancel'
      Left = 110
      Top = 130
      Width = 80
      Height = 30
      OnClick = btnCancelNewClick
    end
  end
end
