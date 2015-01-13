Option Compare Database
Option Explicit

' Default Usage:
' The following folders are used if no custom configuration is provided:
' aegitType.SourceFolder = "C:\ae\aegit\aerc\src\"
' aegitType.aegitXMLfolder = "C:\ae\aegit\aerc\src\xml\"
' Run in immediate window:                  aegit_EXPORT
' Show debug output in immediate window:    aegit_EXPORT varDebug:="varDebug"
'                                           aegit_EXPORT 1
'
' Custom Usage:
' Public Const THE_SOURCE_FOLDER = "Z:\The\Source\Folder\src.MYPROJECT\"
' Public Const THE_XML_FOLDER = "Z:\The\Source\Folder\src.MYPROJECT\xml\"
' For custom configuration of the output source folder in aegitClassTest use:
' oDbObjects.SourceFolder = THE_SOURCE_FOLDER
' oDbObjects.XMLfolder = THE_XML_FOLDER
' Run in immediate window:                  ALTERNATIVE_EXPORT
' Show debug output in immediate window:    ALTERNATIVE_EXPORT varDebug:="varDebug"
'                                           ALTERNATIVE_EXPORT 1
'

Public Function aegit_EXPORT(Optional ByVal varDebug As Variant) As Boolean
    On Error GoTo 0
    If Not IsMissing(varDebug) Then
        aegitClassTest varDebug:="varDebug"
    Else
        aegitClassTest
    End If
End Function

Public Sub ALTERNATIVE_EXPORT(Optional ByVal varDebug As Variant)

    Dim THE_SOURCE_FOLDER As String
    THE_SOURCE_FOLDER = "C:\TEMP\aealt\src\"
    Dim THE_XML_FOLDER As String
    THE_XML_FOLDER = "C:\TEMP\aealt\src\xml\"

    On Error GoTo PROC_ERR

    If Not IsMissing(varDebug) Then
        aegitClassTest varDebug:="varDebug", varSrcFldr:=THE_SOURCE_FOLDER, varXmlFldr:=THE_XML_FOLDER
    Else
        aegitClassTest varSrcFldr:=THE_SOURCE_FOLDER, varXmlFldr:=THE_XML_FOLDER
    End If

PROC_EXIT:
    Exit Sub

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure ALTERNATIVE_EXPORT"
    Resume Next

End Sub

Private Function PassFail(ByVal bln As Boolean, Optional ByVal varOther As Variant) As String
    On Error GoTo 0
    If Not IsMissing(varOther) Then
        PassFail = "NotUsed"
        Exit Function
    End If
    If bln Then
        PassFail = "Pass"
    Else
        PassFail = "Fail"
    End If
End Function

Private Function IsArrayInitialized(arr As Variant) As Boolean
    If Not IsArray(arr) Then Err.Raise 13
    On Error Resume Next
    IsArrayInitialized = (LBound(arr) <= UBound(arr))
End Function

Public Function aegitClassTest(Optional ByVal varDebug As Variant, _
                                Optional ByVal varSrcFldr As Variant, _
                                Optional ByVal varXmlFldr As Variant, _
                                Optional ByVal varXmlData As Variant) As Boolean

    On Error GoTo PROC_ERR

    Const AEGIT_FILES_NOT_EXCLUDED As Boolean = True

    Dim oDbObjects As aegit_expClass
    Set oDbObjects = New aegit_expClass

    Dim bln1 As Boolean
    Dim bln2 As Boolean
    Dim bln3 As Boolean
    Dim bln4 As Boolean
    Dim bln5 As Boolean
    Dim bln6 As Boolean
    Dim bln7 As Boolean
    Dim bln8 As Boolean

    If Not IsMissing(varSrcFldr) Then oDbObjects.SourceFolder = varSrcFldr      ' THE_SOURCE_FOLDER
    If Not IsMissing(varXmlFldr) Then oDbObjects.XMLfolder = varXmlFldr         ' THE_XML_FOLDER
    If Application.VBE.ActiveVBProject.Name = "aegit" Then
        oDbObjects.ExcludeFiles = AEGIT_FILES_NOT_EXCLUDED
        Debug.Print "oDbObjects.ExcludeFiles = " & oDbObjects.ExcludeFiles
    End If

    ' Define tables for xml data export
    If Not IsMissing(varXmlData) Then
            If Application.VBE.ActiveVBProject.Name = "aegit" Then
                Dim myArray() As Variant
                myArray = Array("tblRace", "tblYear")
                oDbObjects.TablesExportToXML = myArray()
            Else
                If IsArrayInitialized(gvarMyTablesForExportToXML) Then
                    Debug.Print "UBound(gvarMyTablesForExportToXML)=" & UBound(gvarMyTablesForExportToXML)
                    oDbObjects.TablesExportToXML = gvarMyTablesForExportToXML
                Else
                    Debug.Print "Array gvarMyTablesForExportToXML is not initialized! There are no tables selected for export."
                End If
            End If
    End If

Test1:
    '=============
    ' TEST 1
    '=============
    oDbObjects.ExcludeFiles = False
    oDbObjects.ExportQAT = False
    Debug.Print
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "1. aegitClassTest => DocumentTheDatabase"
    Debug.Print "aegitClassTest"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to DocumentTheDatabase"
        Debug.Print , "DEBUGGING IS OFF"
        bln1 = oDbObjects.DocumentTheDatabase()
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to DocumentTheDatabase"
        Debug.Print , "DEBUGGING TURNED ON"
        bln1 = oDbObjects.DocumentTheDatabase("WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

Test2:
    '=============
    ' TEST 2
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "2. aegitClassTest => Exists"
    Debug.Print "aegitClassTest"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to Exists"
        Debug.Print , "DEBUGGING IS OFF"
        bln2 = oDbObjects.Exists("Modules", "zzzaegitClass")
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to Exists"
        Debug.Print , "DEBUGGING TURNED ON"
        bln2 = oDbObjects.Exists("Modules", "zzzaegitClass", "WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

Test3:
    '=============
    ' TEST 3
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "3. NOT USED"
    Debug.Print "aegitClassTest"

    bln3 = False

    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

Test4:
    '=============
    ' TEST 4
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "4. aegitClassTest => GetReferences"
    Debug.Print "aegitClassTest"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to GetReferences"
        Debug.Print , "DEBUGGING IS OFF"
        bln4 = oDbObjects.GetReferences()
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to GetReferences"
        Debug.Print , "DEBUGGING TURNED ON"
        bln4 = oDbObjects.GetReferences("WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print
    
Test5:
    '=============
    ' TEST 5
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "5. aegitClassTest => DocumentTables"
    Debug.Print "aegitClassTest"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to DocumentTables"
        Debug.Print , "DEBUGGING IS OFF"
        bln5 = oDbObjects.DocumentTables()
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to DocumentTables"
        Debug.Print , "DEBUGGING TURNED ON"
        bln5 = oDbObjects.DocumentTables("WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print
    
Test6:
    '=============
    ' TEST 6
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "6. aegitClassTest => DocumentRelations"
    Debug.Print "aegitClassTest"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to DocumentRelations"
        Debug.Print , "DEBUGGING IS OFF"
        bln6 = oDbObjects.DocumentRelations()
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to DocumentRelations"
        Debug.Print , "DEBUGGING TURNED ON"
        bln6 = oDbObjects.DocumentRelations("WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

Test7:
    '=============
    ' TEST 7
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "7. aegitClassTestXML => DocumentTablesXML"
    Debug.Print "aegitClassTestXML"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so no parameter is passed to DocumentTheDatabase"
        Debug.Print , "DEBUGGING IS OFF"
        bln7 = oDbObjects.DocumentTablesXML()
    Else
        Debug.Print , "varDebug IS NOT missing so a variant parameter is passed to DocumentTheDatabase"
        Debug.Print , "DEBUGGING TURNED ON"
        bln7 = oDbObjects.DocumentTablesXML("WithDebugging")
    End If
    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

Test8:
    '=============
    ' TEST 8
    '=============
    Debug.Print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    Debug.Print "8. NOT USED"
    Debug.Print "aegitClassTest"

    bln8 = False

    Debug.Print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    Debug.Print

RESULTS:
    Debug.Print "Test 1: DocumentTheDatabase"
    Debug.Print "Test 2: Exists"
    Debug.Print "Test 3: NOT USED"
    Debug.Print "Test 4: GetReferences"
    Debug.Print "Test 5: DocumentTables"
    Debug.Print "Test 6: DocumentRelations"
    Debug.Print "Test 7: DocumentTablesXML"
    Debug.Print "Test 8: NOT USED"
    Debug.Print
    Debug.Print "Test 1", "Test 2", "Test 3", "Test 4", "Test 5", "Test 6", "Test 7", "Test 8"
    Debug.Print PassFail(bln1), PassFail(bln2), PassFail(bln3, "X"), PassFail(bln4), PassFail(bln5), PassFail(bln6), PassFail(bln7), PassFail(bln8, "X")

PROC_EXIT:
    Exit Function

PROC_ERR:
    Select Case Err.Number
        Case Else
            MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aegitClassTest"
            Stop
    End Select

End Function