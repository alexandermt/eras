object DMOracle: TDMOracle
  OldCreateOrder = False
  Height = 150
  Width = 220
  object qryApplicants: TUniQuery
    SQL.Strings = (
      'SELECT 1 FROM DUAL')
    Left = 40
    Top = 40
  end
  object qryApplicantDetail: TUniQuery
    SQL.Strings = (
      'SELECT 1 FROM DUAL')
    Left = 120
    Top = 40
  end
end
