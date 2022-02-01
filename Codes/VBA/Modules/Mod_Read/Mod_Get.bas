Attribute VB_Name = "Mod_Get"
Option Explicit
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function GetFileName(ByVal FileSpec As String) As String
On Error GoTo Err

    '�t�@�C���� �擾
    Dim FSO As New FileSystemObject
    GetFileName = FSO.GetFileName(FileSpec)

    Exit Function

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function GetPath(ByVal Spec As String) As String
On Error GoTo Err

    '�t�@�C���� �擾
    Dim FSO As New FileSystemObject
    GetPath = FSO.GetParentFolderName(Spec)

    Exit Function

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function GetSelectFileSpec() As String
On Error GoTo Err

    '�_�C�A���O�{�b�N�X �ݒ�
    With Application.FileDialog(msoFileDialogFilePicker)
        .AllowMultiSelect = False
        With .Filters
            .Clear
            Call .Add("Excel �t�@�C��", "*.xls*", 1)
        End With
        .FilterIndex = 1
        .Title = "Excel �t�@�C�� �I��"
        .InitialFileName = CurDir()

        '�t�H���_�I����� ����
        If .Show = -1 Then GetSelectFileSpec = .SelectedItems(1)
    End With

    Exit Function

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------

'----------------------------------------------------------------------------------------------------
Public Function GetSelectFolderSpec() As String
On Error GoTo Err

    '�_�C�A���O�{�b�N�X �ݒ�
    With Application.FileDialog(msoFileDialogFolderPicker)
        .AllowMultiSelect = False
        .Title = "�t�H���_ �I��"

        '�t�H���_�I����� ����
        If .Show = -1 Then GetSelectFolderSpec = .SelectedItems(1)
    End With

    Exit Function

'�G���[����
Err:

    Call ShowErrMsg(Err.Description, Err.Number)

End Function
'----------------------------------------------------------------------------------------------------
