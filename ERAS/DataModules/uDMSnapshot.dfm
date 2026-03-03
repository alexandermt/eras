object DMSnapshot: TDMSnapshot
  OldCreateOrder = False
  Height = 150
  Width = 280
  object qrySnapshots: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 40
    Top = 40
  end
  object dsSnapshots: TDataSource
    DataSet = qrySnapshots
    Left = 120
    Top = 40
  end
  object qrySnapshotApplicants: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 200
    Top = 40
  end
end
