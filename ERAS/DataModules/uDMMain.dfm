object DMMain: TDMMain
  OldCreateOrder = False
  Height = 200
  Width = 320
  object conMariaDB: TUniConnection
    ProviderName = 'MySQL'
    Left = 40
    Top = 40
  end
  object conOracle: TUniConnection
    ProviderName = 'Oracle'
    Left = 160
    Top = 40
  end
  object PythonEngine1: TPythonEngine
    AutoLoad = False
    Left = 40
    Top = 120
  end
  object PythonDelphiVar1: TPythonDelphiVar
    Engine = PythonEngine1
    VarName = 'delphi_var'
    Left = 160
    Top = 120
  end
end
