object DMAudit: TDMAudit
  OldCreateOrder = False
  Height = 150
  Width = 220
  object qryAuditInsert: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 40
    Top = 40
  end
  object qryAuditList: TUniQuery
    SQL.Strings = (
      'SELECT 1')
    Left = 120
    Top = 40
  end
end
