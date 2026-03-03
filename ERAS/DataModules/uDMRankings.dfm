object DMRankings: TDMRankings
  OldCreateOrder = False
  Height = 150
  Width = 280
  object qryRankings: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 40
    Top = 40
  end
  object dsRankings: TDataSource
    DataSet = qryRankings
    Left = 120
    Top = 40
  end
  object qryBulkUpdate: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 200
    Top = 40
  end
end
