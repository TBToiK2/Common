Attribute VB_Name = "Module1"
Option Explicit
'----------------------------------------------------------------------------------------------------
'2022/12/06 14:38:55
'----------------------------------------------------------------------------------------------------
Public Sub ReplaceModule()
On Error GoTo Err:

    '�e�v���Z�X ��~
    Dim beforeCalc As XlCalculation
    Call BeforeProcess(beforeCalc)

    '���W���[���u���Ώۃt�@�C��, �t�H���_�f�B���N�g�� �擾
    Dim targetFileSpec As String
    Dim targetFolderSpec As String
    If Not SelectFileFolderSpec(targetFileSpec, targetFolderSpec) Then Exit Sub

    If IsOpen(targetFileSpec) = -1 Then
        Call ShowErrMsg("���ɑI�������t�@�C�����J���Ă��邽�߁A�����𒆎~���܂��B" & vbLf & "���Ă����蒼���Ă��������B")
        GoTo Err_After
    End If

    '���W���[���f�B�N�V���i�� �쐬
    Dim moduleFileDIC As Dictionary
    Set moduleFileDIC = GetModuleFileDIC(targetFolderSpec)

    If moduleFileDIC.Count = 0 Then
        Call ShowErrMsg("�I�������t�H���_����bas�t�@�C�������݂��Ȃ����߁A�����𒆎~���܂��B")
        GoTo Err_After
    End If

    '���W���[���u���ΏۃG�N�Z���v���Z�X ��~
    Dim ExcelApp As New Excel.Application
    Dim ExcelAppBeforeCalc As XlCalculation
    Call BeforeProcess(ExcelAppBeforeCalc, ExcelApp, True)

    '���W���[���u���Ώۃt�@�C�� �I�[�v��
    With ExcelApp
        Dim wb As Workbook
        Set wb = .Workbooks.Open(targetFileSpec)
    End With

    Dim VBCs As VBComponents
    Set VBCs = wb.VBProject.VBComponents

    '�u���Ώۃ��W���[�� �i�荞��
    Dim VBC As VBComponent
    For Each VBC In VBCs
        If VBC.Type = vbext_ct_StdModule And moduleFileDIC.Exists(VBC.Name) Then
            Dim replaceVBCDIC As New Dictionary
            Call replaceVBCDIC.Add(VBC, moduleFileDIC(VBC.Name))
        End If
    Next VBC

    If replaceVBCDIC.Count = 0 Then
        Call ShowErrMsg("�u���Ώۃ��W���[�������݂��Ȃ����߁A�����𒆎~���܂��B")
        GoTo Err_After
    End If

    '���W���[�� �u��
    Dim VBCDICKey As Variant
    For Each VBCDICKey In replaceVBCDIC.Keys
        Call VBCs.Remove(VBCDICKey)
        Call VBCs.Import(replaceVBCDIC(VBCDICKey))
    Next VBCDICKey

    '���W���[���u���Ώۃt�@�C�� �ۑ�
    Call wb.Save
    Call wb.Close(False)

    Call MsgBox("�u������")

    '���W���[���u���ΏۃG�N�Z���v���Z�X �ĊJ
    Call AfterProcess(ExcelAppBeforeCalc, ExcelApp, True)
    Call ExcelApp.Quit

    '�e�v���Z�X �ĊJ
    Call AfterProcess(beforeCalc)

    Exit Sub

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

Err_After:

    If Not wb Is Nothing Then Call wb.Close(False)

    '���W���[���u���ΏۃG�N�Z���v���Z�X �ĊJ
    Call AfterProcess(ExcelAppBeforeCalc, ExcelApp, True)
    Call ExcelApp.Quit

    '�e�v���Z�X �ĊJ
    Call AfterProcess(beforeCalc)

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/12/06 14:38:52
'----------------------------------------------------------------------------------------------------
Public Function SelectFileFolderSpec(ByRef targetFileSpec As String, ByRef targetFolderSpec As String) As Boolean

    Dim FSO As New FileSystemObject

    Dim wbPath As String
    wbPath = ReplaceOneDrivePath(ThisWorkbook.path)

    '���W���[���u���Ώۃt�@�C�� �I��
    With Application.FileDialog(msoFileDialogFilePicker)
        With .Filters
            Call .Clear
            Call .Add("Excel �t�@�C��", "*.xlsm, *.xlam")
        End With
        .InitialFileName = FSO.BuildPath(wbPath, Application.PathSeparator)
        .FilterIndex = 1
        .AllowMultiSelect = False
        .Title = "���W���[���u���Ώۃt�@�C�� �I��"
        .InitialFileName = vbNullString

        If .Show = -1 Then
            targetFileSpec = .SelectedItems(1)
        Else
            Exit Function
        End If
    End With

    '���W���[���i�[�t�H���_ �I��
    With Application.FileDialog(msoFileDialogFolderPicker)
        .AllowMultiSelect = False
        .Title = "���W���[���i�[�t�H���_ �I��"
        .InitialFileName = FSO.BuildPath(wbPath, Application.PathSeparator)

        If .Show = -1 Then
            targetFolderSpec = .SelectedItems(1)
        Else
            Exit Function
        End If
    End With

    SelectFileFolderSpec = True

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/12/06 14:38:48
'----------------------------------------------------------------------------------------------------
Public Function GetModuleFileDIC(ByVal targetFolderSpec As String) As Dictionary

    Dim FSO As New FileSystemObject
    Dim moduleFileDIC As New Dictionary

    Dim moduleFile As File
    For Each moduleFile In FSO.GetFolder(targetFolderSpec).Files
        Dim elm As Long
        If FSO.GetExtensionName(moduleFile.Name) = "bas" Then
            Call moduleFileDIC.Add(FSO.GetBaseName(moduleFile.Name), moduleFile.path)
        End If
    Next moduleFile

    Set GetModuleFileDIC = moduleFileDIC

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'
'----------------------------------------------------------------------------------------------------
Public Function IsOpen(ByVal fileSpec As String) As Long
On Error Resume Next

    IsOpen = 1

    Dim fileNumber As Long
    '�t�@�C���i���o�[1-255
    fileNumber = FreeFile(0)
    '�t�@�C���i���o�[256-512
    If fileNumber = 0 Then fileNumber = FreeFile(1)

    '�t�@�C���i���o�[ �S�g�p��
    If Err.Number = 67 Then Exit Function

    '�J�m�F(Append)
    Open fileSpec For Append As #fileNumber
    Close #fileNumber

    '�ǂݎ���p����
    If Err.Number = 75 Then
        '�J�m�F(Input)
        Open fileSpec For Input As #fileNumber
        Close #fileNumber
    End If

    IsOpen = Err.Number = 55 Or Err.Number = 70

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/12/06 14:38:44
'----------------------------------------------------------------------------------------------------
Public Function ReplaceOneDrivePath(ByVal path As String)

    'OneDrive�p�X ����
    If Not path Like "https://*" Then
        ReplaceOneDrivePath = path
        Exit Function
    End If

    '���ݒ� �擾
    Dim OneDriveCommercialPath As String, OneDriveConsumerPath As String
    OneDriveCommercialPath = IIf(Environ("OneDriveCommercial") = "", Environ("OneDrive"), Environ("OneDriveCommercial"))
    OneDriveConsumerPath = IIf(Environ("OneDriveConsumer") = "", Environ("OneDrive"), Environ("OneDriveConsumer"))

    Dim filePathPos As Long
    '�@�l����
    If path Like "*my.sharepoint.com*" Then

        filePathPos = InStr(path, "/Documents") + Len("/Documents")

        ReplaceOneDrivePath = OneDriveCommercialPath & Replace(Mid(path, filePathPos), "/", Application.PathSeparator)

    '�l����
    Else

        filePathPos = InStr(Len("https://") + 1, path, "/")
        filePathPos = InStr(filePathPos + 1, path, "/")

        If filePathPos = 0 Then
            ReplaceOneDrivePath = OneDriveConsumerPath
        Else
            ReplaceOneDrivePath = OneDriveConsumerPath & Replace(Mid(path, filePathPos), "/", Application.PathSeparator)
        End If

    End If

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/12/06 15:31:21
'----------------------------------------------------------------------------------------------------
Public Sub AfterProcess(Optional ByVal calculation As XlCalculation, Optional ByRef excelApp As Excel.Application, Optional ByVal isWbOpening As Boolean)

    '���� ����l����
    If excelApp Is Nothing Then Set excelApp = Excel.Application

    '�e�v���Z�X �ĊJ
    With excelApp
        .ScreenUpdating = True
        .DisplayAlerts = True
        .EnableEvents = True
        If Not isWbOpening Then
            .CutCopyMode = False
            .StatusBar = False
        End If
        If .Workbooks.Count > 0 Then
            .Calculation = calculation
        End If
    End With

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/12/06 15:31:21
'----------------------------------------------------------------------------------------------------
Public Sub BeforeProcess(Optional ByRef calculation As XlCalculation, Optional ByRef excelApp As Excel.Application, Optional ByVal isWbOpening As Boolean)

    '���� ����l����
    If excelApp Is Nothing Then Set excelApp = Excel.Application

    '�e�v���Z�X ��~
    With excelApp
        .ScreenUpdating = False
        .DisplayAlerts = False
        .EnableEvents = False
        If Not isWbOpening Then
            .StatusBar = False
        End If
        If .Workbooks.Count > 0 Then
            calculation = .Calculation
            .Calculation = xlCalculationManual
        End If
    End With

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'2022/03/17 09:59:52
'----------------------------------------------------------------------------------------------------
Public Sub ShowErrMsg(ByVal errDescription As String, Optional ByVal errNumber As Long, Optional ByVal title As String)
On Error Resume Next

    '���b�Z�[�W�v�����v�g �ݒ�
    Dim prompt As String
    prompt = "�G���[���e:[" & vbCrLf & errDescription & vbCrLf & "]"
    If errNumber <> 0 Then Prompt = "�G���[�ԍ�:[" & errNumber & "]" & vbCrLf & prompt

    '�^�C�g�� �ݒ�
    If title <> "" Then title = ":" & title

    '���b�Z�[�W �\��
    Call MsgBox(prompt, vbOKOnly + vbCritical, "�G���[" & title)

    Err.Clear

End Sub
'----------------------------------------------------------------------------------------------------