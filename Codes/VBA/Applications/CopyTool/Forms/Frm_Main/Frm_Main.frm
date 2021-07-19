VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Frm_Main 
   ClientHeight    =   9420.001
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   14565
   OleObjectBlob   =   "Frm_Main.frx":0000
   StartUpPosition =   1  '�I�[�i�[ �t�H�[���̒���
End
Attribute VB_Name = "Frm_Main"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'----------------------------------------------------------------------------------------------------
'�m�F���b�Z�[�W
Private Const INF_BACK_ON  As String = "�o�b�N�O���E���h�ŏ������s���܂��B��낵���ł����H"
Private Const INF_BACK_OFF As String = "�������s���܂��B" & vbCrLf & _
                                        "�u�Z�L�����e�B�x���v�_�C�A���O���\�����ꂽ�ꍇ�́A�K��" & vbCrLf & _
                                        "�u�}�N����L���ɂ���v��I�����Ă��������B" & vbCrLf & _
                                        "���u�}�N���𖳌��ɂ���v��I�������ꍇ�A�������~�܂�܂��B" & vbCrLf & _
                                        "��낵���ł����H"

'���ʃp�����[�^
Private g_ExcelApp      As Application '�R�s�[�pExcel�I�u�W�F�N�g
Private g_ParamSh       As Worksheet   '�p�����[�^�ݒ�V�[�g
Private g_ParamShName   As String      '�p�����[�^�ݒ�V�[�g��
Private g_BackgroundFLG As Boolean     '�o�b�N�O���E���h����
Private g_LogFLG        As Boolean     '�X�V���O�쐬
Private g_FormatFLG     As Boolean     '�����R�s�[
Private g_BlankFLG      As Boolean     '�󔒃R�s�[
Private g_AutoSaveFLG   As Boolean     '�R�s�[��I�[�g�Z�[�u
Private g_BackupFLG     As Boolean     '�R�s�[��o�b�N�A�b�v
Private g_ChangeMarkCol As Long        '�R�s�[��ύX�s�}�[�N
Private g_FontColor     As Long        '�R�s�[�Z�������F
Private g_InteriorColor As Long        '�R�s�[�Z���w�i�F

'�t�@�C���ʃp�����[�^ (F���R�s�[��, T���R�s�[��)
Private g_FWb        As Workbook, g_TWb     As Workbook '�R�s�[�惏�[�N�u�b�N
Private g_FFileSpec  As String, g_TFileSpec As String   '�t�@�C���p�X
Private g_FFileName  As String, g_TFileName As String   '�t�@�C����
Private g_FShName    As String, g_TShName   As String   '�V�[�g��
Private g_FPswd      As String, g_TPswd     As String   '�p�X���[�h
Private g_FItemIDRow As Long, g_TItemIDRow  As Long     '����ID�s
Private g_FStartCol  As Long, g_TStartCol   As Long     '���ڊJ�n��
Private g_FDataIDCol As Long, g_TDataIDCol  As Long     '�f�[�^ID��
Private g_FStartRow  As Long, g_TStartRow   As Long     '�f�[�^�J�n�s

'�R�s�[�Ώۃe�[�u��
Private g_CopyItemArr() As Variant           '�R�s�[�Ώۍ��ڔz��
Private Const COPYCOL_START_ROW As Long = 22 '�R�s�[�Ώۍ��ڐ擪�s
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Const GWL_STYLE = -16
Private Const WS_SYSMENU = &H80000

#If VBA7 Then

    Private Declare PtrSafe Function GetWindowLong Lib "user32.dll" Alias "GetWindowLongA" _
        (ByVal hWnd As LongPtr, ByVal nIndex As Long) As LongPtr
    
    Private Declare PtrSafe Function SetWindowLongPtr Lib "user32.dll" Alias "SetWindowLongPtrA" _
        (ByVal hWnd As LongPtr, ByVal nIndex As Long, ByVal dwNewLong As LongPtr) As LongPtr
    
    Private Declare PtrSafe Function GetActiveWindow Lib "user32.dll" () As LongPtr
    
    Private Declare PtrSafe Function DrawMenuBar Lib "user32.dll" (ByVal hWnd As LongPtr) As Long

#Else

    Private Declare Function GetWindowLong Lib "user32.dll" Alias "GetWindowLongA" _
        (ByVal hWnd As Long, ByVal nIndex As Long) As Long
    
    Private Declare Function SetWindowLong Lib "user32.dll" Alias "SetWindowLongA" _
        (ByVal hWnd As Long, ByVal nIndex As Long, _
         ByVal dwNewLong As Long) As Long
    
    Private Declare Function GetActiveWindow Lib "user32.dll" () As Long
    
    Private Declare Function DrawMenuBar Lib "user32.dll" (ByVal hWnd As Long) As Long
#End If
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub UserForm_Activate()

    '����{�^�� ����
    #If VBA7 Then
        Dim hWnd As LongPtr
        Dim Wnd_STYLE As LongPtr
    #Else
        Dim hWnd As Long
        Dim Wnd_STYLE As Long
    #End If

    hWnd = GetActiveWindow()
    Wnd_STYLE = GetWindowLong(hWnd, GWL_STYLE)
    Wnd_STYLE = Wnd_STYLE And (Not WS_SYSMENU)

    #If VBA7 Then
        Call SetWindowLongPtr(hWnd, GWL_STYLE, Wnd_STYLE)
    #Else
        Call SetWindowLong(hWnd, GWL_STYLE, Wnd_STYLE)
    #End If

    DrawMenuBar hWnd

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub UserForm_Initialize()
On Error GoTo Err

    '�t�H�[���L���v�V���� �ݒ�
    With Main
        Frm_Main.Caption = .Cells(1, 1).Value & " " & .Cells(1, 19).Value
    End With

    Dim ThisWorksheets As Sheets
    Set ThisWorksheets = ThisWorkbook.Worksheets
    '�V�[�g�L�� �m�F
    If Not HasWorksheet(ThisWorksheets, "Main", True) Then
        Call ShowErrMsg("�R�s�[�c�[�����Ɏ��s�V�[�g�����݂��܂���B")
        End
    End If

    '�R���{�{�b�N�X �l�ǉ�
    Dim ws As Worksheet
    For Each ws In ThisWorksheets
        If ws.CodeName <> "Main" And ws.CodeName <> "Template" Then
            Cmb_ShName.AddItem ws.Name
        End If
    Next ws

    '�o�b�N�O���E���h���[�h ������
    Ckb_Background.Value = False

    Exit Sub

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

    '�t�H�[�� �I��
    End

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub Cmb_ShName_Change()
On Error Resume Next

    With ThisWorkbook.Sheets(Cmb_ShName.Value)
        '�t�@�C���p�X �\��
        Lbl_FPath.Caption = .Range("C13")
        Lbl_TPath.Caption = .Range("D13")
    End With

    '�I������ �ۑ�
    g_ParamShName = Cmb_ShName.Value

    'OK�{�^�� �t�H�[�J�X
    Btn_OK.SetFocus

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub Btn_ChangeFPath_Click()
On Error Resume Next

    '�V�[�g �I�𔻒�
    Dim Path As String
    If IsBlank(g_ParamShName) Then
        Call ShowErrMsg("�ΏۃV�[�g���I������Ă��܂���B" & vbCrLf & "�V�[�g��I�����Ă��������B")
        Exit Sub
    Else
        Path = GetPath(Lbl_FPath.Caption)
        If Not FolderExists(Path) Then Path = ThisWorkbook.Path
    End If

    '�J�����g�h���C�u�E�f�B���N�g�� ������
    If Left(Path, 2) = "\\" Then
        CreateObject("WScript.Shell").CurrentDirectory = Path
    Else
        Call ChDrive(Path)
        Call ChDir(Path)
    End If

    If Err.Number > 0 Then
        Path = ThisWorkbook.Path
        '�J�����g�h���C�u�E�f�B���N�g�� ������
        If Left(Path, 2) = "\\" Then
            CreateObject("WScript.Shell").CurrentDirectory = Path
        Else
            Call ChDrive(Path)
            Call ChDir(Path)
        End If
    End If

    '�I���t�@�C���� �擾
    Dim FileSpec As String
    FileSpec = GetSelectFileSpec()

    '�t�@�C�� �I�𔻒�
    If Not IsBlank(FileSpec) Then
        '�I���t�@�C���� ���f
        Lbl_FPath.Caption = FileSpec
        ThisWorkbook.Sheets(g_ParamShName).Range("C13").Value = FileSpec
    End If

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub Btn_ChangeTPath_Click()
On Error Resume Next

    '�V�[�g �I�𔻒�
    Dim Path As String
    If IsBlank(g_ParamShName) Then
        Call ShowErrMsg("�ΏۃV�[�g���I������Ă��܂���B" & vbCrLf & "�V�[�g��I�����Ă��������B")
        Exit Sub
    Else
        Path = GetPath(Lbl_TPath.Caption)
        If Not FolderExists(Path) Then Path = ThisWorkbook.Path
    End If

    '�J�����g�h���C�u�E�f�B���N�g�� ������
    If Left(Path, 2) = "\\" Then
        CreateObject("WScript.Shell").CurrentDirectory = Path
    Else
        Call ChDrive(Path)
        Call ChDir(Path)
    End If

    If Err.Number > 0 Then
        Path = ThisWorkbook.Path
        '�J�����g�h���C�u�E�f�B���N�g�� ������
        If Left(Path, 2) = "\\" Then
            CreateObject("WScript.Shell").CurrentDirectory = Path
        Else
            Call ChDrive(Path)
            Call ChDir(Path)
        End If
    End If

    '�I���t�@�C���� �擾
    Dim FileSpec As String
    FileSpec = GetSelectFileSpec()

    '�t�@�C�� �I�𔻒�
    If Not IsBlank(FileSpec) Then
        '�I���t�@�C���� ���f
        Lbl_TPath.Caption = FileSpec
        ThisWorkbook.Sheets(g_ParamShName).Range("D13").Value = FileSpec
    End If

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub Btn_OK_Click()
On Error GoTo Err

    '�V�[�g �I�𔻒�
    If IsBlank(g_ParamShName) Then
        Call ShowErrMsg("�ΏۃV�[�g���I������Ă��܂���B" & vbCrLf & "�V�[�g��I�����Ă��������B")
        Exit Sub
    End If

    '�o�b�N�O���E���h���� �m�F
    g_BackgroundFLG = Ckb_Background.Value
    If g_BackgroundFLG Then
        If ShowInfoMsg(INF_BACK_ON) = vbCancel Then Exit Sub
    Else
        If ShowInfoMsg(INF_BACK_OFF) = vbCancel Then Exit Sub
    End If


Dim t As Double
t = Timer


    '�p�����[�^ �m�F
    If Not CheckParamData() Then Exit Sub

    '�g�p�t�@�C�����ǂݎ���p�ŊJ���Ă���ꍇ�́A��U�N���[�Y
    '���v���Z�X�ňȍ~�̏��������s�����ہA�t�@�C�����d�������
    Dim wb As Workbook
    For Each wb In Workbooks
        With wb
            If .ReadOnly And (.FullName = g_FFileSpec Or .FullName = g_TFileSpec) Then
                Call .Close(SaveChanges:=False)
            End If
        End With
    Next

    '�t�@�C�� �J�m�F
    '�R�s�[��
    If IsOpen(g_FFileSpec) Then
        ShowErrMsg ("�R�s�[�� �t�@�C�����g�p���ł��B�I�����Ă��������B")
        Exit Sub
    End If
    '�R�s�[��
    If IsOpen(g_TFileSpec) Then
        ShowErrMsg ("�R�s�[�� �t�@�C�����g�p���ł��B�I�����Ă��������B")
        Exit Sub
    End If

    '�R�s�[��t�@�C�� ������r
    If CompareAttr(g_TFileSpec, vbReadOnly) Then
        ShowErrMsg ("�R�s�[�� �t�@�C���̑������ǂݎ���p�ł��B�I�����Ă��������B")
        Exit Sub
    End If

    '�R�s�[��t�@�C�� �o�b�N�A�b�v
    If g_BackupFLG Then
        If Not BackupFile(g_TFileSpec) Then Exit Sub
    End If

    '�o�b�N�O���E���h���� ����
    If g_BackgroundFLG Then

        'Excel�I�u�W�F�N�g �擾
        Set g_ExcelApp = New Excel.Application

        With g_ExcelApp
            .DisplayAlerts = False

            '�}�N���x���_�C�A���O �l�ۑ�
            Dim AutoSecurity As MsoAutomationSecurity
            AutoSecurity = .AutomationSecurity
            '�}�N���x���_�C�A���O �l�ύX
            .AutomationSecurity = msoAutomationSecurityForceDisable

            '�t�@�C�� �I�[�v��
            '�R�s�[��
            Call .Workbooks.Open(g_FFileSpec, ReadOnly:=True, Notify:=False, Password:=g_FPswd)
            Set g_FWb = .ActiveWorkbook
            '�R�s�[��
            Call .Workbooks.Open(g_TFileSpec, ReadOnly:=False, IgnoreReadOnlyRecommended:=True, Notify:=False, Password:=g_TPswd)
            Set g_TWb = .ActiveWorkbook

            '�}�N���x���_�C�A���O �l����
            .AutomationSecurity = AutoSecurity

            .DisplayAlerts = True
        End With

    Else

        'Excel�I�u�W�F�N�g �擾
        Set g_ExcelApp = Excel.Application

        '����t�@�C���� ���݊m�F
        '�R�s�[��
        If HasWorkbook(g_ExcelApp.Workbooks, g_FFileName) Then
            Call ShowErrMsg("�R�s�[���Ɠ����̃t�@�C�����J����Ă��܂��B�I�����ĉ������B")
            Exit Sub
        End If
        '�R�s�[��
        If HasWorkbook(g_ExcelApp.Workbooks, g_TFileName) Then
            Call ShowErrMsg("�R�s�[��Ɠ����̃t�@�C�����J����Ă��܂��B�I�����ĉ������B")
            Exit Sub
        End If

        With g_ExcelApp
            .DisplayAlerts = False

            '�t�@�C�� �I�[�v��
            '�R�s�[��
            Call .Workbooks.Open(g_FFileSpec, ReadOnly:=True, Notify:=False, Password:=g_FPswd)
            Set g_FWb = .ActiveWorkbook
            '�R�s�[��
             Call .Workbooks.Open(g_TFileSpec, ReadOnly:=False, IgnoreReadOnlyRecommended:=True, Notify:=False, Password:=g_TPswd)
            Set g_TWb = .ActiveWorkbook

            .DisplayAlerts = True
        End With
    End If

    Dim BeforeCalc As Long
    '�e�v���Z�X ��~
    Call BeforeProcess(BeforeCalc, g_ExcelApp)

    '�V�[�g ���݊m�F
    '�R�s�[��
    If Not HasWorksheet(g_FWb.Sheets, g_FShName) Then
        Call ShowErrMsg("�R�s�[�� �t�@�C�����Ɏw�肳�ꂽ�V�[�g�����݂��܂���" & vbCrLf & "�V�[�g��: " & g_FShName)
        Exit Sub
    End If
    '�R�s�[��
    If Not HasWorksheet(g_TWb.Sheets, g_TShName) Then
        Call ShowErrMsg("�R�s�[�� �t�@�C�����Ɏw�肳�ꂽ�V�[�g�����݂��܂���" & vbCrLf & "�V�[�g��: " & g_TShName)
        Exit Sub
    End If

    '�f�[�^ �R�s�[
    Dim CopiedCount As Long
    If Not DataCopy(CopiedCount) Then
        Call ShowErrMsg("�f�[�^�̃R�s�[�Ɏ��s���܂����B")
        GoTo ErrAfter
    End If

    '�����ۑ� ����
    If g_AutoSaveFLG Then Call g_TWb.Save


Debug.Print "Btn_OK_Click:" & (Timer - t) & "�b"


    '���b�Z�[�W �\��
    Call MsgBox("�f�[�^�̃R�s�[���I�����܂����" & vbCrLf & "��������: " & CopiedCount & "���ł��B", vbOKOnly)

    '�R�s�[��t�@�C�� �\��
    g_ExcelApp.Visible = True

    '�e�v���Z�X �ĊJ
    Call AfterProcess(BeforeCalc, g_ExcelApp)

    Call CloseWorkbook
    Call Unload(Me)

    Exit Sub

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

ErrAfter:

    '�e�v���Z�X �ĊJ
    Call AfterProcess(BeforeCalc, g_ExcelApp)

    Call CloseWorkbook(True)
    Call Unload(Me)

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub Btn_Cancel_Click()
On Error Resume Next

    '�����I��
    Unload Me

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function CheckParamData() As Boolean
On Error GoTo Err


Dim t As Double
t = Timer


    '�p�����[�^�A�h���X �ݒ�
    Dim LogAddress As String, FormatAddress As String, BlankAddress As String, AutoSaveAddress As String, BackupAddress As String
    Dim ChangeMarkAddress As String, FontAddress As String, InteriorAddress As String
    Dim FFileSpecAddress As String, TFileSpecAddress As String, FShNameAddress As String, TShNameAddress As String
    Dim FItemIDAddress As String, TItemIDAddress As String, FStartColAddress As String, TStartColAddress As String
    Dim FDataIDAddress As String, TDataIDAddress As String, FStartRowAddress As String, TStartRowAddress As String
    Dim FPassAddress As String, TPassAddress As String
    LogAddress = "$C$3":        FormatAddress = "$C$4":     BlankAddress = "$C$5":      AutoSaveAddress = "$C$6": BackupAddress = "$C$7"
    ChangeMarkAddress = "$C$8": FontAddress = "$C$9":       InteriorAddress = "$C$10"
    FFileSpecAddress = "$C$13": TFileSpecAddress = "$D$13": FShNameAddress = "$C$14":   TShNameAddress = "$D$14"
    FItemIDAddress = "$C$15":   TItemIDAddress = "$D$15":   FStartColAddress = "$C$16": TStartColAddress = "$D$16"
    FDataIDAddress = "$C$17":   TDataIDAddress = "$D$17":   FStartRowAddress = "$C$18": TStartRowAddress = "$D$18"
    FPassAddress = "$C$19":     TPassAddress = "$D$19"

    Set g_ParamSh = ThisWorkbook.Sheets(g_ParamShName)

    '�p�����[�^ �m�F
    With g_ParamSh

        Dim ErrParam As String
        '�X�V���O�쐬
        If Not ConvertTrueFalse(.Range(LogAddress).Value, g_LogFLG) Then ErrParam = ErrParam & vbCrLf & "�X�V���O�쐬"
        '�����R�s�[
        If Not ConvertTrueFalse(.Range(FormatAddress).Value, g_FormatFLG) Then ErrParam = ErrParam & vbCrLf & "�����R�s�["
        '�󔒃R�s�[
        If Not ConvertTrueFalse(.Range(BlankAddress).Value, g_BlankFLG) Then ErrParam = ErrParam & vbCrLf & "�󔒃R�s�["
        '�R�s�[��I�[�g�Z�[�u
        If Not ConvertTrueFalse(.Range(AutoSaveAddress).Value, g_AutoSaveFLG) Then ErrParam = ErrParam & vbCrLf & "�R�s�[��I�[�g�Z�[�u"
        '�R�s�[��o�b�N�A�b�v
        If Not ConvertTrueFalse(.Range(BackupAddress).Value, g_BackupFLG) Then ErrParam = ErrParam & vbCrLf & "�R�s�[��o�b�N�A�b�v"

        '�R�s�[��ύX�s�}�[�N
        If Not IsBlank(.Range(ChangeMarkAddress).Value) Then
            If Not ConvertColumnReference(xlR1C1, .Range(ChangeMarkAddress).Value, g_ChangeMarkCol) Then
                ErrParam = ErrParam & vbCrLf & "�R�s�[��ύX�}�[�N�s"
            End If
        End If

        '�R�s�[�Z�������F
        g_FontColor = .Range(FontAddress).Font.Color
        '�R�s�[�Z���w�i�F
        g_InteriorColor = .Range(InteriorAddress).Interior.Color

        '�t�@�C���p�X
        g_FFileSpec = .Range(FFileSpecAddress).Value
        g_TFileSpec = .Range(TFileSpecAddress).Value
        If IsBlank(g_FFileSpec) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �t�@�C���p�X"
        If IsBlank(g_TFileSpec) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �t�@�C���p�X"

        '�t�@�C����
        g_FFileName = GetFileName(g_FFileSpec)
        g_TFileName = GetFileName(g_TFileSpec)
        If IsBlank(g_FFileName) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �t�@�C����"
        If IsBlank(g_TFileName) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �t�@�C����"

        '�V�[�g��
        g_FShName = .Range(FShNameAddress).Value
        g_TShName = .Range(TShNameAddress).Value
        If IsBlank(g_FShName) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �V�[�g��"
        If IsBlank(g_TShName) Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �V�[�g��"

        '����ID�s
        g_FItemIDRow = Int(Val(.Range(FItemIDAddress).Value))
        g_TItemIDRow = Int(Val(.Range(TItemIDAddress).Value))
        If g_FItemIDRow < MIN_ROW Or g_FItemIDRow > MAX_ROW Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� ����ID�s"
        If g_TItemIDRow < MIN_ROW Or g_TItemIDRow > MAX_ROW Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� ����ID�s"

        '���ڊJ�n��
        If Not ConvertColumnReference(ByVal xlR1C1, .Range(FStartColAddress).Value, g_FStartCol) Then
            ErrParam = ErrParam & vbCrLf & "�R�s�[�� ���ڊJ�n��"
        End If
        If Not ConvertColumnReference(ByVal xlR1C1, .Range(TStartColAddress).Value, g_TStartCol) Then
            ErrParam = ErrParam & vbCrLf & "�R�s�[�� ���ڊJ�n��"
        End If

        '�f�[�^ID��
        If Not ConvertColumnReference(ByVal xlR1C1, .Range(FDataIDAddress).Value, g_FDataIDCol) Then
            ErrParam = ErrParam & vbCrLf & "�R�s�[�� �f�[�^ID��"
        End If
        If Not ConvertColumnReference(ByVal xlR1C1, .Range(TDataIDAddress).Value, g_TDataIDCol) Then
            ErrParam = ErrParam & vbCrLf & "�R�s�[�� �f�[�^ID��"
        End If

        '�f�[�^�J�n�s
        g_FStartRow = Int(Val(.Range(FStartRowAddress).Value))
        g_TStartRow = Int(Val(.Range(TStartRowAddress).Value))
        If g_FStartRow < MIN_ROW Or g_FStartRow > MAX_ROW Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �f�[�^�J�n�s"
        If g_TStartRow < MIN_ROW Or g_TStartRow > MAX_ROW Then ErrParam = ErrParam & vbCrLf & "�R�s�[�� �f�[�^�J�n�s"

        '�p�X���[�h
        g_FPswd = .Range("C19").Value
        g_TPswd = .Range("C19").Value

        If Not IsBlank(ErrParam) Then
            Call ShowErrMsg("�ȉ��̃p�����[�^���s���ł��B�ݒ肵�Ȃ����Ă��������B" & ErrParam)
            GoTo Err_Config
        End If

        '�R�s�[�Ώۍ���ID �󔒊m�F
        If .Cells(Rows.Count, 2).End(xlUp).Row < COPYCOL_START_ROW Then
            Call ShowErrMsg("����ID��1���ݒ肳��Ă��܂���B�ݒ肵�Ă��������B")
            GoTo Err_Config
        End If

        '�R�s�[�Ώۍ��ڔz�� �擾
        '1��ځF���ږ�
        '2��ځF����ID
        '3��ځF�ʍ���ID
        g_CopyItemArr = .Range(.Cells(COPYCOL_START_ROW, 1), .Cells(.Cells(Rows.Count, 2).End(xlUp).Row, 3)).Value

    End With

    Dim CopyColIndex As Long
    For CopyColIndex = 1 To UBound(g_CopyItemArr, 1)

        Dim FCopyCol As Long
        If IsBlank(g_CopyItemArr(CopyColIndex, 2)) Then
            Call ShowErrMsg("�ȉ��̍��ږ��̍���ID���ݒ肳��Ă��܂���B�ݒ肵�Ă��������B" & vbCrLf & g_CopyItemArr(CopyColIndex, 1))
            GoTo Err_Config
        End If

    Next CopyColIndex

    '�t�@�C�� ���݊m�F
    If Not FileExists(g_FFileSpec) Then
        Call ShowErrMsg("�R�s�[�� �t�@�C�������݂��܂���")
        Exit Function
    End If
    If Not FileExists(g_FFileSpec) Then
        Call ShowErrMsg("�R�s�[�� �t�@�C�������݂��܂���")
        Exit Function
    End If


Debug.Print "CheckParamData:" & (Timer - t) & "�b"


    CheckParamData = True

    Exit Function

'�G���[����
Err_Config:

    g_ParamSh.Activate

    Exit Function

Err:

    Call ShowErrMsg(Err.Number, Err.Description)

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Function DataCopy(ByRef CopiedCount As Long) As Boolean
On Error GoTo Err


Dim t As Double
t = Timer


    '�u�������v�t�H�[�� �\��
    Dim BarMaxWidth As Single
    With Frm_Progress
        Call .Show(vbModeless)
        BarMaxWidth = .Fra_Progress.Width
        .Lbl_Description.Caption = "�R�s�[���c�c"
    End With

    '�V�[�g �擾
    Dim FSheet As Worksheet, TSheet As Worksheet
    Set FSheet = g_FWb.Sheets(g_FShName)
    Set TSheet = g_TWb.Sheets(g_TShName)

    '�R�s�[�V�[�g �S�\��
    Call ShowAllData(FSheet)
    With TSheet
        If .FilterMode Then Call .ShowAllData
    End With

    '����ID�ő��, �f�[�^ID�ő�s��, ����ID�͈�, �f�[�^ID�͈� �擾
    Dim FEndCol As Long, TEndCol As Long
    Dim FEndRow As Long, TEndRow As Long
    Dim FItemIDArr() As Variant, TItemIDArr() As Variant
    Dim FDataIDArr() As Variant, TDataIDArr() As Variant
    '�R�s�[��
    With FSheet
        FEndCol = .Cells(g_FItemIDRow, .Columns.Count).End(xlToLeft).Column
        FEndRow = .Cells(.Rows.Count, g_FDataIDCol).End(xlUp).Row
        '�z�� ����
        With .Range(.Cells(g_FItemIDRow, g_FStartCol), .Cells(g_FItemIDRow, FEndCol))
            If IsArray(.Value) Then
                FItemIDArr = .Value
            Else
                ReDim FItemIDArr(1 To 1, 1 To 1)
                FItemIDArr(1, 1) = .Value
            End If
        End With
        '�z�� ����
        With .Range(.Cells(g_FStartRow, g_FDataIDCol), .Cells(FEndRow, g_FDataIDCol))
            If IsArray(.Value) Then
                FDataIDArr = .Value
            Else
                ReDim FDataIDArr(1 To 1, 1 To 1)
                FDataIDArr(1, 1) = .Value
            End If
        End With
    End With
    '�R�s�[��
    With TSheet
        TEndCol = .UsedRange.Columns.Count
        TEndRow = .UsedRange.Rows.Count
        '�z�� ����
        With .Range(.Cells(g_TItemIDRow, g_TStartCol), .Cells(g_TItemIDRow, TEndCol))
            If IsArray(.Value) Then
                TItemIDArr = .Value
            Else
                ReDim TItemIDArr(1 To 1, 1 To 1)
                TItemIDArr(1, 1) = .Value
            End If
        End With
        '�z�� ����
        With .Range(.Cells(g_TStartRow, g_TDataIDCol), .Cells(TEndRow, g_TDataIDCol))
            If IsArray(.Value) Then
                TDataIDArr = .Value
            Else
                ReDim TDataIDArr(1 To 1, 1 To 1)
                TDataIDArr(1, 1) = .Value
            End If
        End With
    End With

    '�z��2�����v�f�� �ǉ�
    '4��ځF�R�s�[������ID�e�v�f�ԍ�
    '5��ځF�R�s�[�捀��ID�e�v�f�ԍ�
    ReDim Preserve g_CopyItemArr(1 To UBound(g_CopyItemArr, 1), 1 To UBound(g_CopyItemArr, 2) + 2)

    '�R�s�[�Ώۍ��ڔz�� ���[�v
    Dim CopyItemIDCount As Long
    For CopyItemIDCount = 1 To UBound(g_CopyItemArr, 1)

        '�R�s�[�Ώۍ��ڗv�f �擾
        Dim CopyItemID As Variant, AnotherCopyItemID As Variant
        CopyItemID = g_CopyItemArr(CopyItemIDCount, 2)
        AnotherCopyItemID = g_CopyItemArr(CopyItemIDCount, 3)

        Dim FItemIDCol As Variant, TItemIDCol As Variant
        Dim FItemIDCount As Long, TItemIDCount As Long
        '�R�s�[��
        FItemIDCol = Application.Match(CopyItemID, FItemIDArr, 0)
        If Not IsError(FItemIDCol) Then
            g_CopyItemArr(CopyItemIDCount, 4) = FItemIDCol
            FItemIDCount = FItemIDCount + 1
        End If
        '�R�s�[��
        If IsBlank(AnotherCopyItemID) Then
            TItemIDCol = Application.Match(CopyItemID, TItemIDArr, 0)
        Else
            TItemIDCol = Application.Match(AnotherCopyItemID, TItemIDArr, 0)
        End If
        If Not IsError(TItemIDCol) Then
            g_CopyItemArr(CopyItemIDCount, 5) = TItemIDCol
            TItemIDCount = TItemIDCount + 1
        End If

    Next

    If FItemIDCount * TItemIDCount = 0 Then
        If FItemIDCount = 0 Then Call ShowErrMsg("�R�s�[���t�@�C���ɃR�s�[�Ώۍ��ڂ����݂��܂���B")
        If TItemIDCount = 0 Then Call ShowErrMsg("�R�s�[��t�@�C���ɃR�s�[�Ώۍ��ڂ����݂��܂���B")
        Exit Function
    End If

    '�R�s�[�f�[�^�ێ��p�z��
    Dim CopyData() As String, CopyAllData() As Variant

    ReDim CopyAllData(0)

    '�R�s�[���Ώۍs ���[�v
    Dim FDataRow As Long
    For FDataRow = g_FStartRow To FEndRow

        ReDim CopyData(0)

        '�Ώۍ���ID �擾
        Dim DataID As Variant
        DataID = FDataIDArr(FDataRow - (g_FStartRow - 1), 1)

        '�R�s�[��Ώۍs �擾(����)
        Dim RelDataRow As Variant
        RelDataRow = Application.Match(DataID, TDataIDArr, 0)

        '�R�s�[��Ώۍs �L������
        If Not IsError(RelDataRow) Then

            '�R�s�[��Ώۍs �擾(���)
            Dim TDataRow As Long
            TDataRow = CLng(RelDataRow) + (g_TStartRow - 1)

            '�R�s�[�Ώۍs�z�� �擾
            '�R�s�[��
            Dim FDataRowArr() As Variant, TDataRowArr() As Variant, TDataRowFormulaArr() As Variant
            With FSheet
                With .Range(.Cells(FDataRow, g_FStartCol), .Cells(FDataRow, FEndCol))
                    '�z�� ����
                    If IsArray(.Value) Then
                        FDataRowArr = .Value
                    Else
                        ReDim FDataRowArr(1 To 1, 1 To 1)
                        FDataRowArr(1, 1) = .Value
                    End If
                End With
            End With
            '�R�s�[��
            With TSheet
                With .Range(.Cells(TDataRow, g_TStartCol), .Cells(TDataRow, TEndCol))
                    '�z�� ����
                    If IsArray(.Value) Then
                        TDataRowArr = .Value

                        On Error GoTo Err_Formula

                        TDataRowFormulaArr = .Formula

                    Else
                        ReDim TDataRowArr(1 To 1, 1 To 1)
                        ReDim TDataRowFormulaArr(1 To 1, 1 To 1)
                        TDataRowArr(1, 1) = .Value

                        On Error GoTo Err_Formula

                        TDataRowFormulaArr(1, 1) = .Formula

                    End If
                End With

                GoTo Skip

Err_Formula:

                'Formula����������(8221����)�Y���Z�� ����
                ReDim TDataRowFormulaArr(1 To 1, 1 To TEndCol - g_TStartCol + 1)
                Dim Cell As Range
                For Each Cell In .Range(.Cells(TDataRow, g_TStartCol), .Cells(TDataRow, TEndCol))
                    With Cell
                        If .HasFormula Then
                            TDataRowFormulaArr(1, .Column - g_TStartCol + 1) = .Formula
                        Else
                            TDataRowFormulaArr(1, .Column - g_TStartCol + 1) = .Value
                        End If
                    End With
                Next Cell

            End With

Skip:

            On Error GoTo Err

            '�R�s�[�Ώۍ��ڔz�� ���[�v
            Dim CopyItemCount As Long
            For CopyItemCount = 1 To UBound(g_CopyItemArr, 1)

                '�R�s�[�Ώۍ��ڗv�f �擾
                Dim CopyItemFNo As Long, CopyItemTNo As Long
                CopyItemFNo = g_CopyItemArr(CopyItemCount, 4)
                CopyItemTNo = g_CopyItemArr(CopyItemCount, 5)

                '�R�s�[�Ώۍ��� �L������
                If CopyItemFNo * CopyItemTNo = 0 Then GoTo Continue

                '�R�s�[�ΏۃZ���l �擾
                Dim FValue As Variant, TValue As Variant
                FValue = FDataRowArr(1, CopyItemFNo)
                TValue = TDataRowArr(1, CopyItemTNo)

                '�Z���l �G���[����
                '�R�s�[��
                If IsError(FValue) Then GoTo Continue
                '�R�s�[��
                If IsError(TValue) Then GoTo Continue

                '�R�s�[���󔒎����� ����
                If Not (Not g_BlankFLG And IsBlank(Trim(FValue))) Then

                    '�Z���l ��r
                    If CStr(FValue) <> CStr(TValue) Then

                        '����ID �z��ǉ�
                        If IsBlank(CopyData(0)) Then CopyData(0) = DataID

                        '�R�s�[�ΏۃZ����L�� �擾
                        Dim FDataCol As String, TDataCol As String
                        If Not ConvertColumnReference(xlA1, FDataCol, CopyItemFNo + (g_FStartCol - 1)) Then
                            Exit Function
                        End If
                        If Not ConvertColumnReference(xlA1, TDataCol, CopyItemTNo + (g_TStartCol - 1)) Then
                            Exit Function
                        End If

                        If g_LogFLG Then
                            '�R�s�[�f�[�^ �z��i�[
                            '���ږ�[�A�h���X], �R�s�[���Z���l, �R�s�[��Z���l �z��ǉ�
                            Dim AddCopyDataCount As Long
                            AddCopyDataCount = UBound(CopyData, 1) + 3
                            ReDim Preserve CopyData(AddCopyDataCount)
                            CopyData(AddCopyDataCount - 2) = g_CopyItemArr(CopyItemCount, 1) & "[" & FDataCol & FDataRow & ", " & TDataCol & TDataRow & "]"
                            CopyData(AddCopyDataCount - 1) = FValue
                            CopyData(AddCopyDataCount) = TValue
                        End If

                        '�ύX�l �z�񔽉f
                        TDataRowFormulaArr(1, CopyItemTNo) = FValue

                        '�R�s�[�Z�� �擾
                        Dim FCell As Range, TCell As Range
                        '�R�s�[��
                        Set FCell = FSheet.Range(FDataCol & FDataRow)
                        '�R�s�[��
                        Set TCell = TSheet.Range(TDataCol & TDataRow)

                        '�����R�s�[�t���O ����
                        If g_FormatFLG Then
                            Call FCell.Copy(Destination:=TCell)
                        Else
                            '�����F �ύX
                            TCell.Font.Color = g_FontColor
                            '�w�i�F �ύX
                            TCell.Interior.Color = g_InteriorColor
                        End If
                    End If
                End If

Continue:
            Next CopyItemCount

            If Not IsBlank(CopyData(0)) Then

                With TSheet
                    '�R�s�[��Ώۍs ���f
                    .Range(.Cells(TDataRow, g_TStartCol), .Cells(TDataRow, TEndCol)).Value = TDataRowFormulaArr
                    '�������t ���f
                    If g_ChangeMarkCol > 0 Then .Cells(TDataRow, g_ChangeMarkCol) = Date
                End With

                '���O�p�ύX�f�[�^ �z��i�[
                If g_LogFLG And UBound(CopyData, 1) > 0 Then
                    CopyAllData(UBound(CopyAllData, 1)) = CopyData
                    ReDim Preserve CopyAllData(UBound(CopyAllData, 1) + 1)
                End If

                '�������� �J�E���g
                CopiedCount = CopiedCount + 1
            End If
        End If

        '�t�H�[�� �X�V
        Dim FCopyRatio As Long, TCopyRatio As Long
        TCopyRatio = (FDataRow - (g_FStartRow - 1)) * 100 \ (FEndRow - (g_FStartRow - 1))
        If TCopyRatio <> FCopyRatio Then
            Frm_Progress.Lbl_ProgressBar.Width = BarMaxWidth * TCopyRatio / 100
            Call Frm_Progress.Repaint
            FCopyRatio = TCopyRatio
        End If

        DoEvents

    Next FDataRow

    '�R�s�[��V�[�g �A�N�e�B�x�[�g
    TSheet.Activate

    '���O�o�� ����
    If g_LogFLG And CopiedCount > 0 Then
    
        '�u���O�o�͒��v�t�H�[�� �\��
        Frm_Progress.Lbl_Description.Caption = "���O�o�͒��c�c"

        '���O�p�V�[�g �쐬
        Dim LogSh As Worksheet
        Set LogSh = ThisWorkbook.Sheets.Add

        '���O �o��
        Dim CopyMaxCount
        Dim LogCount As Long
        For LogCount = 0 To UBound(CopyAllData, 1) - 1

            '���O�o�͍ő�l �擾
            Dim MaxCopyData As Long
            MaxCopyData = UBound(CopyAllData(LogCount), 1)
            CopyMaxCount = WorksheetFunction.Max(CopyMaxCount, MaxCopyData)

            '2�s�ڈȍ~ ���O�o��
            With LogSh
                .Range(.Cells(2 + LogCount, 1), .Cells(2 + LogCount, MaxCopyData)).Value = CopyAllData(LogCount)
            End With

            '�t�H�[�� �X�V
            Dim FLogRatio As Long, TLogRatio As Long
            TLogRatio = LogCount * 100 \ UBound(CopyAllData, 1)
            If TLogRatio <> FLogRatio Then
                Frm_Progress.Lbl_ProgressBar.Width = BarMaxWidth * TLogRatio / 100
                Call Frm_Progress.Repaint
                FLogRatio = TLogRatio
            End If

        Next LogCount

        '���O���o�� �o��
        Dim LogTitle() As String
        ReDim Preserve LogTitle(CopyMaxCount) As String
        LogTitle(0) = "�f�[�^ID"
        Dim LogTitleCount
        For LogTitleCount = 1 To UBound(LogTitle, 1) Step 3
            LogTitle(LogTitleCount) = "���ږ�, �A�h���X[��, ��]"
            LogTitle(LogTitleCount + 1) = "�R�s�[���Z���l"
            LogTitle(LogTitleCount + 2) = "�R�s�[��Z���l"
        Next LogTitleCount
        With LogSh
            .Range(.Cells(1, 1), .Cells(1, 1 + UBound(LogTitle, 1))).Value = LogTitle
        End With

        '�Z����, �r�� �ݒ�
        With LogSh.UsedRange
            Call .Columns.AutoFit
            .Borders.LineStyle = True
        End With

        '���O�Ƃ��ĐV�K�u�b�N��
        Call LogSh.Copy
        '���V�[�g�폜
        Application.DisplayAlerts = False
        On Error Resume Next
        Call LogSh.Delete
        On Error GoTo 0
        Application.DisplayAlerts = False

    End If


Debug.Print "DataCopy:" & (Timer - t) & "�b"


    '�t�H�[�� �I��
    Call Unload(Frm_Progress)

    DataCopy = True

    Exit Function

'�G���[����
Err:

    '�t�H�[�� �I��
    Call Unload(Frm_Progress)

    Call ShowErrMsg(Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Private Sub CloseWorkbook(Optional ByVal ErrFLG As Boolean)
On Error Resume Next

    '�t�@�C�� �N���[�Y
    '�R�s�[��
    If Not IsBlank(g_FWb) Then
        Call g_FWb.Close(SaveChanges:=False)
    End If
    If ErrFLG Then
        '�R�s�[��
        If Not IsBlank(g_TWb) Then
            Call g_TWb.Close(SaveChanges:=False)
        End If

        '�o�b�N�O���E���h���� ����
        If g_BackgroundFLG Then
            If Not IsBlank(g_ExcelApp) Then Call g_ExcelApp.Quit
        End If
    End If

End Sub
'----------------------------------------------------------------------------------------------------
