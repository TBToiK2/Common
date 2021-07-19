Attribute VB_Name = "Mod_Common"
Option Explicit
'----------------------------------------------------------------------------------------------------
Public Const MIN_ROW = 1
Public Const MAX_ROW = 1048576
Public Const MIN_COL = 1
Public Const MAX_COL = 16384

'----------------------------------------------------------------------------------------------------
Public Function ShowInfoMsg(ByVal Prompt As String) As Long
On Error Resume Next

    '���b�Z�[�W �\��
    ShowInfoMsg = MsgBox(Prompt, vbOKOnly + vbInformation, "���")

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function ShowQuestionMsg(ByVal Prompt As String) As Long
On Error Resume Next

    '���b�Z�[�W �\��
    ShowInfoMsg = MsgBox(Prompt, vbOKCancel + vbQuestion, "�m�F")

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Sub ShowErrMsg(ByVal Description As String, Optional ByVal Number As Long)
On Error Resume Next

    '���b�Z�[�W�v�����v�g �ݒ�
    Dim Prompt As String
    Prompt = "�G���[���e:[" & vbCrLf & Description & vbCrLf & "]"
    If Number <> 0 Then Prompt = "�G���[�ԍ�:[" & Number & "]" & vbCrLf & Prompt

    '���b�Z�[�W �\��
    Call MsgBox(Prompt, vbOKOnly + vbCritical, "�G���[")

    Err.Clear

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Sub ShowAllData(ByVal ws As Worksheet)

    With ws
        '�t�B���^�[ ����
        If .FilterMode Then Call .ShowAllData

        '�s�� �S�\��
        .Cells.EntireColumn.Hidden = False
        .Cells.EntireRow.Hidden = False
    End With

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Sub BeforeProcess(ByRef Calculation As XlCalculation, Optional ByRef ExcelApp As Application)

    '�I�u�W�F�N�g�L�� ����
    If IsBlank(ExcelApp) Then
        With Application
            Calculation = .Calculation
            .Calculation = xlCalculationManual
            .ScreenUpdating = False
            .DisplayAlerts = False
            .EnableEvents = False
        End With
        DoEvents
    Else
        With ExcelApp
            If .Workbooks.Count > 0 Then
                Calculation = .Calculation
                .Calculation = xlCalculationManual
            End If
            .ScreenUpdating = False
            .DisplayAlerts = False
            .EnableEvents = False
        End With
        DoEvents
    End If

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Sub AfterProcess(ByVal Calculation As XlCalculation, Optional ByRef ExcelApp As Application)

    '�I�u�W�F�N�g�L�� ����
    If IsBlank(ExcelApp) Then
        With Excel.Application
            .Calculation = Calculation
            .CutCopyMode = False
            .ScreenUpdating = True
            .DisplayAlerts = True
            .EnableEvents = True
        End With
        DoEvents
    Else
        With ExcelApp
            If .Workbooks.Count > 0 Then
                .Calculation = Calculation
            End If
            .CutCopyMode = False
            .ScreenUpdating = True
            .DisplayAlerts = True
            .EnableEvents = True
        End With
        DoEvents
    End If

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function BackupFile(ByVal FileSpec As String) As Boolean
On Error GoTo Err

    Dim FSO As New FileSystemObject
    Dim BaseName As String, ExtensionName As String

    '�t�@�C�����E�g���q �擾
    BaseName = FSO.GetBaseName(FileSpec)
    ExtensionName = FSO.GetExtensionName(FileSpec)

    Call FileCopy(FileSpec, ThisWorkbook.Path & "\" & BaseName & "_" & CStr(Format(Now(), "yymmddhhmmss")) & "." & ExtensionName)

    BackupFile = True

    Exit Function

'�G���[����
Err:

    Call ShowErrMsg("�t�@�C���̃R�s�[(�o�b�N�A�b�v)�����s���܂����B" & vbCrLf & Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------
