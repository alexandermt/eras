object DMWorkspace: TDMWorkspace
  OldCreateOrder = False
  Height = 150
  Width = 280
  object qryWorkspaces: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 40
    Top = 40
  end
  object dsWorkspaces: TDataSource
    DataSet = qryWorkspaces
    Left = 120
    Top = 40
  end
  object qryWorkspaceDetail: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 200
    Top = 40
  end
end
