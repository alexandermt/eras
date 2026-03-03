object SnapshotForm: TSnapshotForm
  Caption = 'Snapshots'
  ClientHeight = 600
  ClientWidth = 900
  OnCreate = UniFormCreate
  object pnlToolbar: TUniPanel
    Align = alTop
    Height = 40
    object btnNewSnap: TUniButton
      Caption = 'New Snapshot'
      Left = 8
      Top = 6
      Width = 120
      Height = 28
      OnClick = btnNewSnapClick
    end
    object btnOpenRank: TUniButton
      Caption = 'Open Rankings'
      Left = 136
      Top = 6
      Width = 120
      Height = 28
      OnClick = btnOpenRankClick
    end
    object btnFreeze: TUniButton
      Caption = 'Freeze'
      Left = 264
      Top = 6
      Width = 80
      Height = 28
      OnClick = btnFreezeClick
    end
  end
  object grdSnapshots: TUniDBGrid
    Align = alClient
    Top = 40
    Columns = <
      item
        FieldName = 'label'
        Title.Caption = 'Label'
        Width = 200
      end
      item
        FieldName = 'created_at'
        Title.Caption = 'Created'
        Width = 150
      end
      item
        FieldName = 'created_by_name'
        Title.Caption = 'Created By'
        Width = 150
      end
      item
        FieldName = 'frozen'
        Title.Caption = 'Frozen'
        Width = 60
      end
      item
        FieldName = 'frozen_at'
        Title.Caption = 'Frozen At'
        Width = 150
      end>
  end
  object pnlNewSnap: TUniPanel
    Align = alBottom
    Height = 100
    Visible = False
    object lblSnapLabel: TUniLabel
      Caption = 'Snapshot Label:'
      Left = 20
      Top = 20
    end
    object edtSnapLabel: TUniEdit
      Left = 20
      Top = 40
      Width = 300
    end
    object btnSaveSnap: TUniButton
      Caption = 'Create'
      Left = 20
      Top = 66
      Width = 80
      Height = 28
      OnClick = btnSaveSnapClick
    end
    object btnCancelSnap: TUniButton
      Caption = 'Cancel'
      Left = 110
      Top = 66
      Width = 80
      Height = 28
      OnClick = btnCancelSnapClick
    end
  end
end
