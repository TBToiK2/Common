Attribute VB_Name = "Module1"
Option Explicit
'----------------------------------------------------------------------------------------------------
'
'----------------------------------------------------------------------------------------------------
Public Sub ReplaceModule()
On Error GoTo Err:

    '�e�v���Z�X ��~
    With Application
        .ScreenUpdating = False
        .EnableEvents = False
        .DisplayAlerts = False
        .StatusBar = False
    End With

    '���W���[���u���Ώۃt�@�C��, �t�H���_�f�B���N�g�� �擾
    Dim targetFileSpec As String
    Dim targetFolderSpec As String
    If Not SelectFileFolderSpec(targetFileSpec, targetFolderSpec) Then Exit Sub

    If IsOpen(targetFileSpec) = -1 Then
        Call MsgBox("���ɑI�������t�@�C�����J���Ă��邽�߁A�����𒆎~���܂��B" & vbLf & "���Ă����蒼���Ă��������B")
        Exit Sub
    End If

    '���W���[���f�B�N�V���i�� �쐬
    Dim moduleFileDIC As Dictionary
    Set moduleFileDIC = GetModuleFileDIC(targetFolderSpec)

    If moduleFileDIC.Count = 0 Then Exit Sub

    '���W���[���u���ΏۃG�N�Z���v���Z�X ��~
    Dim ExcelApp As New Excel.Application
    With ExcelApp
        .ScreenUpdating = False
        .EnableEvents = False
        .DisplayAlerts = False
        .StatusBar = False

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

    '���W���[�� �u��
    Dim VBCDICKey As Variant
    For Each VBCDICKey In replaceVBCDIC.Keys
        Call VBCs.Remove(VBCDICKey)
        Call VBCs.Import(replaceVBCDIC(VBCDICKey))
    Next VBCDICKey

    Call wb.Save

    Call MsgBox("�u������")

Err:

    If Not wb Is Nothing Then Call wb.Close(False)

    '���W���[���u���ΏۃG�N�Z���v���Z�X �ĊJ
    With ExcelApp
        .ScreenUpdating = True
        .EnableEvents = True
        .DisplayAlerts = True
        .StatusBar = False

        Call .Quit
    End With

    '�e�v���Z�X �ĊJ
    With Application
        .ScreenUpdating = True
        .EnableEvents = True
        .DisplayAlerts = True
        .StatusBar = False
    End With

End Sub
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
'
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
'
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
'
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