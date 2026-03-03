object LoginForm: TLoginForm
  Caption = 'ERAS - Login'
  ClientHeight = 400
  ClientWidth = 400
  object pnlCenter: TUniPanel
    AlignmentParam = 'center'
    Width = 320
    Height = 280
    Left = 40
    Top = 60
    object lblTitle: TUniLabel
      Caption = 'ERAS - Enterprise Ranking && Admissions System'
      Left = 10
      Top = 10
      Width = 300
      StyleName = 'title'
    end
    object lblUsername: TUniLabel
      Caption = 'Username:'
      Left = 20
      Top = 70
    end
    object edtUsername: TUniEdit
      Left = 20
      Top = 90
      Width = 260
      TabOrder = 0
    end
    object lblPassword: TUniLabel
      Caption = 'Password:'
      Left = 20
      Top = 130
    end
    object edtPassword: TUniEdit
      Left = 20
      Top = 150
      Width = 260
      PasswordChar = '*'
      TabOrder = 1
    end
    object btnLogin: TUniButton
      Caption = 'Login'
      Left = 20
      Top = 210
      Width = 260
      Height = 36
      TabOrder = 2
      OnClick = btnLoginClick
    end
  end
end
