Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Database
Option Explicit

'Copyright (c) 2011 Peter F. Ennis
'This library is free software; you can redistribute it and/or
'modify it under the terms of the GNU Lesser General Public
'License as published by the Free Software Foundation;
'version 3.0.
'This library is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
'Lesser General Public License for more details.
'You should have received a copy of the GNU Lesser General Public
'License along with this library; if not, visit
'http://www.gnu.org/licenses/lgpl-3.0.txt
'
' Ref: http://www.di-mgt.com.au/cl_Simple.html
'=======================================================================
' Author:   Peter F. Ennis
' Date:     February 24, 2011
' Comment:  Create class for revision control
' Updated:  All notes moved to change log
' History:  See comment details, basChangeLog, commit messages on github
'=======================================================================

Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal lngMilliSeconds As Long)

Private Const aegit_impVERSION As String = "1.0.0"
Private Const aegit_impVERSION_DATE As String = "May 23, 2014"
Private Const aeAPP_NAME As String = "aegit_imp"
'''x Private Const aeDEBUG_PRINT As Boolean = True
Private Const THE_DRIVE As String = "C"

Private Const mblnHandleErrors As Boolean = True

Private Type mySetupType
    ImportFolder As String
    NotUsed As Boolean
End Type

Private aegitType As mySetupType
Private aegitImportFolder As String
Private aestrImportLocation As String
'

Private Sub Class_Initialize()
' Ref: http://www.cadalyst.com/cad/autocad/programming-with-class-part-1-5050
' Ref: http://www.bigresource.com/Tracker/Track-vb-cyJ1aJEyKj/
' Ref: http://stackoverflow.com/questions/1731052/is-there-a-way-to-overload-the-constructor-initialize-procedure-for-a-class-in

    On Error GoTo 0
    ' provide default values
    aegitImportFolder = "default"
    aegitType.ImportFolder = "C:\ae\aegit\aerc\src\imp\"

    Debug.Print "Class_Initialize"
    Debug.Print , "Default for aegitImportFolder = " & aegitImportFolder
    Debug.Print , "Default for aegitType.ImportFolder = " & aegitType.ImportFolder

End Sub

Private Sub Class_Terminate()
'''     Dim strFile As String
'''     strFile = aegitSourceFolder & "export.ini"
'''     If Dir$(strFile) <> vbNullString Then
'''         ' The file exists
'''         If Not FileLocked(strFile) Then KillProperly (strFile)
'''     End If
    On Error GoTo 0
    Debug.Print
    Debug.Print "Class_Terminate"
    Debug.Print , "aegit_imp VERSION: " & aegit_impVERSION
    Debug.Print , "aegit_imp VERSION_DATE: " & aegit_impVERSION_DATE
End Sub

Public Property Get ImportFolder() As String
    On Error GoTo 0
    ImportFolder = aegitImportFolder
End Property

Public Property Let ImportFolder(ByVal strImportFolder As String)
    On Error GoTo 0
    aegitImportFolder = strImportFolder
End Property

Public Property Get Exists(ByVal strAccObjType As String, _
                        ByVal strAccObjName As String, _
                        Optional ByVal DebugTheCode As Variant) As Boolean
    On Error GoTo 0
    If IsMissing(DebugTheCode) Then
        Debug.Print "Get Exists"
        Debug.Print , "DebugTheCode IS missing so no parameter is passed to aeExists"
        Debug.Print , "DEBUGGING IS OFF"
        Exists = aeExists(strAccObjType, strAccObjName)
    Else
        Debug.Print "Get Exists"
        Debug.Print , "DebugTheCode IS NOT missing so a variant parameter is passed to aeExists"
        Debug.Print , "DEBUGGING TURNED ON"
        Exists = aeExists(strAccObjType, strAccObjName, DebugTheCode)
    End If
End Property

Public Property Get ReadDocDatabase(ByVal blnImport As Boolean, Optional ByVal DebugTheCode As Variant) As Boolean
    On Error GoTo 0
    If IsMissing(DebugTheCode) Then
        Debug.Print "Get ReadDocDatabase"
        Debug.Print , "DebugTheCode IS missing so no parameter is passed to aeReadDocDatabase"
        Debug.Print , "DEBUGGING IS OFF"
        ReadDocDatabase = aeReadDocDatabase(blnImport)
    Else
        Debug.Print "Get ReadDocDatabase"
        Debug.Print , "DebugTheCode IS NOT missing so a variant parameter is passed to aeReadDocDatabase"
        Debug.Print , "DEBUGGING TURNED ON"
        ReadDocDatabase = aeReadDocDatabase(blnImport, DebugTheCode)
    End If
End Property

Public Property Get GetReferences(Optional ByVal DebugTheCode As Variant) As Boolean
    On Error GoTo 0
    If IsMissing(DebugTheCode) Then
        Debug.Print "Get GetReferences"
        Debug.Print , "DebugTheCode IS missing so no parameter is passed to aeGetReferences"
        Debug.Print , "DEBUGGING IS OFF"
        GetReferences = aeGetReferences
    Else
        Debug.Print "Get GetReferences"
        Debug.Print , "DebugTheCode IS NOT missing so a variant parameter is passed to aeGetReferences"
        Debug.Print , "DEBUGGING TURNED ON"
        GetReferences = aeGetReferences(DebugTheCode)
    End If
End Property

Public Property Get DocumentRelations(Optional ByVal DebugTheCode As Variant) As Boolean
    On Error GoTo 0
    If IsMissing(DebugTheCode) Then
        Debug.Print "Get DocumentRelations"
        Debug.Print , "DebugTheCode IS missing so no parameter is passed to aeDocumentRelations"
        Debug.Print , "DEBUGGING IS OFF"
        DocumentRelations = aeDocumentRelations
    Else
        Debug.Print "Get DocumentRelations"
        Debug.Print , "DebugTheCode IS NOT missing so a variant parameter is passed to aeDocumentRelations"
        Debug.Print , "DEBUGGING TURNED ON"
        DocumentRelations = aeDocumentRelations(DebugTheCode)
    End If
End Property

Public Property Get CompactAndRepair(Optional ByVal varTrueFalse As Variant) As Boolean
' Automation for Compact and Repair

    On Error GoTo 0
    Dim blnRun As Boolean

    Debug.Print "CompactAndRepair"
    If Not IsMissing(varTrueFalse) Then
        blnRun = False
        Debug.Print , "varTrueFalse IS NOT MISSING so blnRun of CompactAndRepair is set to False"
        Debug.Print , "RUN CompactAndRepair IS OFF"
    Else
        blnRun = True
        Debug.Print , "varTrueFalse IS MISSING so blnRun of CompactAndRepair is set to True"
        Debug.Print , "RUN CompactAndRepair IS ON..."
    End If

' TableDefs not refreshed after create
' Ref: http://support.microsoft.com/kb/104339
' So force a compact and repair
' Ref: http://msdn.microsoft.com/en-us/library/office/aa202943(v=office.10).aspx
' Not a "good practice" but for this use it is simple and works
' From the Access window
' Access 2003: SendKeys "%(TDC)", False
' Access 2007: SendKeys "%(FMC)", False
' Access 2010: SendKeys "%(YC)", False
' From the Immediate window
    
    If blnRun Then
        ' Close VBA
        SendKeys "%F{END}{ENTER}", False
        ' Run Compact and Repair
        SendKeys "%F{TAB}{TAB}{ENTER}", False
        CompactAndRepair = True
    Else
        CompactAndRepair = False
    End If
    
End Property

Private Function Pause(ByVal NumberOfSeconds As Variant) As Boolean
' Ref: http://www.access-programmers.co.uk/forums/showthread.php?p=952355

    On Error GoTo PROC_ERR

    Dim PauseTime As Variant
    Dim Start As Variant

    PauseTime = NumberOfSeconds
    Start = Timer
    Do While Timer < Start + PauseTime
        Sleep 100
        DoEvents
    Loop

PROC_EXIT:
    Exit Function

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure Pause of Class aegit_impClass", vbCritical, aeAPP_NAME
    Resume PROC_EXIT

End Function

Private Sub WaitSeconds(ByVal intSeconds As Integer)
' Comments: Waits for a specified number of seconds
' Params  : intSeconds      Number of seconds to wait
' Source  : Total Visual SourceBook
' Ref     : http://www.fmsinc.com/MicrosoftAccess/modules/examples/AvoidDoEvents.asp

    On Error GoTo PROC_ERR

    Dim datTime As Date

    datTime = DateAdd("s", intSeconds, Now)

    Do
        ' Yield to other programs (better than using DoEvents which eats up all the CPU cycles)
        Sleep 100
        DoEvents
    Loop Until Now >= datTime

PROC_EXIT:
    Exit Sub

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure WaitSeconds of Class aegit_impClass", vbCritical, aeAPP_NAME
    Resume PROC_EXIT
End Sub

Private Function aeGetReferences(Optional ByVal varDebug As Variant) As Boolean
' Ref: http://vbadud.blogspot.com/2008/04/get-references-of-vba-project.html
' Ref: http://www.pcreview.co.uk/forums/type-property-reference-object-vbulletin-project-t3793816.html
' Ref: http://www.cpearson.com/excel/missingreferences.aspx
' Ref: http://allenbrowne.com/ser-38.html
' Ref: http://access.mvps.org/access/modules/mdl0022.htm (References Wizard)
' Ref: http://www.accessmvp.com/djsteele/AccessReferenceErrors.html
'====================================================================
' Author:   Peter F. Ennis
' Date:     November 28, 2012
' Comment:  Added and adapted from aeladdin (tm) code
' Updated:  All notes moved to change log
' History:  See comment details, basChangeLog, commit messages on github
'====================================================================

    Dim i As Integer
    Dim blnRefBroken As Boolean
    Dim strFile As String

    Dim vbaProj As Object
    Set vbaProj = Application.VBE.ActiveVBProject

    ' Use a call stack and global error handler
    If mblnHandleErrors Then On Error GoTo PROC_ERR
'    PushCallStack "aeGetReferences"

    Debug.Print "aeGetReferences"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so blnDebug of aeGetReferences is set to False"
        Debug.Print , "DEBUGGING IS OFF"
    Else
        Debug.Print , "varDebug IS NOT missing so blnDebug of aeGetReferences is set to True"
        Debug.Print , "NOW DEBUGGING..."
    End If
   
    If Dir$(strFile) <> vbNullString Then
        ' The file exists
        If Not FileLocked(strFile) Then KillProperly (strFile)
        Open strFile For Append As #1
    Else
        If Not FileLocked(strFile) Then Open strFile For Append As #1
    End If

    If Not IsMissing(varDebug) Then
        Debug.Print ">==> aeGetReferences >==>"
        Debug.Print , "vbaProj.Name = " & vbaProj.Name
        Debug.Print , "vbaProj.Type = '" & vbaProj.Type & "'"
        ' Display the versions of Access, ADO and DAO
        Debug.Print , "Access version = " & Application.Version
        Debug.Print , "ADO (ActiveX Data Object) version = " & CurrentProject.Connection.Version
        Debug.Print , "DAO (DbEngine)  version = " & Application.DBEngine.Version
        Debug.Print , "DAO (CodeDb)    version = " & Application.CodeDb.Version
        Debug.Print , "DAO (CurrentDb) version = " & Application.CurrentDb.Version
        Debug.Print , "<@_@>"
        Debug.Print , "     " & "References:"
    End If

        Print #1, ">==> The Project References >==>"
        Print #1, , "vbaProj.Name = " & vbaProj.Name
        Print #1, , "vbaProj.Type = '" & vbaProj.Type & "'"
        ' Display the versions of Access, ADO and DAO
        Print #1, , "Access version = " & Application.Version
        Print #1, , "ADO (ActiveX Data Object) version = " & CurrentProject.Connection.Version
        Print #1, , "DAO (DbEngine)  version = " & Application.DBEngine.Version
        Print #1, , "DAO (CodeDb)    version = " & Application.CodeDb.Version
        Print #1, , "DAO (CurrentDb) version = " & Application.CurrentDb.Version
        Print #1, , "<@_@>"
        Print #1, , "     " & "References:"

    For i = 1 To vbaProj.References.Count

        blnRefBroken = False

        ' Output reference details
        If Not IsMissing(varDebug) Then
            Debug.Print , , vbaProj.References(i).Name, vbaProj.References(i).Description
            Debug.Print , , , vbaProj.References(i).FullPath
            Debug.Print , , , vbaProj.References(i).GUID
        End If

        Print #1, , , vbaProj.References(i).Name, vbaProj.References(i).Description
        Print #1, , , , vbaProj.References(i).FullPath
        Print #1, , , , vbaProj.References(i).GUID

        ' Returns a Boolean value indicating whether or not the Reference object points to a valid reference in the registry. Read-only.
        If Application.VBE.ActiveVBProject.References(i).IsBroken = True Then
              blnRefBroken = True
              If Not IsMissing(varDebug) Then Debug.Print , , vbaProj.References(i).Name, "blnRefBroken=" & blnRefBroken
              Print #1, , , vbaProj.References(i).Name, "blnRefBroken=" & blnRefBroken
        End If
    Next

    If Not IsMissing(varDebug) Then
        Debug.Print , "<*_*>"
        Debug.Print "<==<"
    End If

    Print #1, , "<*_*>"
    Print #1, "<==<"

    aeGetReferences = True

PROC_EXIT:
    Set vbaProj = Nothing
    Close 1
    Exit Function

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeGetReferences of Class aegit_impClass", vbCritical, aeAPP_NAME
    If Not IsMissing(varDebug) Then Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeGetReferences of Class aegit_impClass"
    aeGetReferences = False
    Resume PROC_EXIT

End Function

Private Function GetLinkedTableCurrentPath(ByVal MyLinkedTable As String) As String
' Ref: http://www.access-programmers.co.uk/forums/showthread.php?t=198057
'=========================================================================
' Procedure : GetLinkedTableCurrentPath
' DateTime  : 08/23/2010
' Author    : Rx
' Purpose   : Returns Current Path of a Linked Table in Access
' Updates   : Peter F. Ennis
' Updated   : All notes moved to change log
' History   : See comment details, basChangeLog, commit messages on github
'=========================================================================
    On Error GoTo PROC_ERR
    GetLinkedTableCurrentPath = Mid$(CurrentDb.TableDefs(MyLinkedTable).Connect, InStr(1, CurrentDb.TableDefs(MyLinkedTable).Connect, "=") + 1)
    ' Non-linked table returns blank - Instr removes the "Database="

PROC_EXIT:
    On Error Resume Next
    Exit Function

PROC_ERR:
    Select Case Err.Number
        ' Case ###         ' Add your own error management or log error to logging table
        Case Else
            ' Add your own custom log usage function
    End Select
    Resume PROC_EXIT
End Function

Private Function FileLocked(ByVal strFileName As String) As Boolean
' Ref: http://support.microsoft.com/kb/209189
    On Error Resume Next
    ' If the file is already opened by another process,
    ' and the specified type of access is not allowed,
    ' the Open operation fails and an error occurs.
    Open strFileName For Binary Access Read Write Lock Read Write As #1
    Close 1
    ' If an error occurs, the document is currently open.
    If Err.Number <> 0 Then
        ' Display the error number and description.
        MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure FileLocked of Class aegit_impClass", vbCritical, aeAPP_NAME
        FileLocked = True
        Err.Clear
    End If
End Function

Private Function GetDescrip(ByVal obj As Object) As String
    On Error Resume Next
    GetDescrip = obj.Properties("Description")
End Function

Private Function IsPK(ByVal tdf As DAO.TableDef, ByVal strField As String) As Boolean
    On Error GoTo 0
    Dim idx As DAO.Index
    Dim fld As DAO.Field
    For Each idx In tdf.Indexes
        If idx.Primary Then
            For Each fld In idx.Fields
                If strField = fld.Name Then
                    IsPK = True
                    Exit Function
                End If
            Next fld
        End If
    Next idx
End Function

Private Function IsIndex(ByVal tdf As DAO.TableDef, ByVal strField As String) As Boolean
    On Error GoTo 0
    Dim idx As DAO.Index
    Dim fld As DAO.Field
    For Each idx In tdf.Indexes
        For Each fld In idx.Fields
            If strField = fld.Name Then
                IsIndex = True
                Exit Function
            End If
        Next fld
    Next idx
End Function

Private Function IsFK(ByVal tdf As DAO.TableDef, ByVal strField As String) As Boolean
    On Error GoTo 0
    Dim idx As DAO.Index
    Dim fld As DAO.Field
    For Each idx In tdf.Indexes
        If idx.Foreign Then
            For Each fld In idx.Fields
                If strField = fld.Name Then
                    IsFK = True
                    Exit Function
                End If
            Next fld
        End If
    Next idx
End Function

Private Function aeDocumentRelations(Optional ByVal varDebug As Variant) As Boolean
' Ref: http://www.tek-tips.com/faqs.cfm?fid=6905
  
    Dim strDocument As String
    Dim rel As DAO.Relation
    Dim fld As DAO.Field
    Dim idx As DAO.Index
    Dim prop As DAO.Property
    Dim strFile As String

    On Error GoTo PROC_ERR

    Debug.Print "aeDocumentRelations"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so blnDebug of aeDocumentRelations is set to False"
        Debug.Print , "DEBUGGING IS OFF"
    Else
        Debug.Print , "varDebug IS NOT missing so blnDebug of aeDocumentRelations is set to True"
        Debug.Print , "NOW DEBUGGING..."
    End If
   
    If Dir$(strFile) <> vbNullString Then
        ' The file exists
        If Not FileLocked(strFile) Then KillProperly (strFile)
        Open strFile For Append As #1
    Else
        If Not FileLocked(strFile) Then Open strFile For Append As #1
    End If

    For Each rel In CurrentDb.Relations
        If Not (Left$(rel.Name, 4) = "MSys" _
                        Or Left$(rel.Name, 4) = "~TMP" _
                        Or Left$(rel.Name, 3) = "zzz") Then
            strDocument = strDocument & vbCrLf & "Name: " & rel.Name & vbCrLf
            strDocument = strDocument & "  " & "Table: " & rel.Table & vbCrLf
            strDocument = strDocument & "  " & "Foreign Table: " & rel.ForeignTable & vbCrLf
            For Each fld In rel.Fields
                strDocument = strDocument & "  PK: " & fld.Name & "   FK:" & fld.ForeignName
                strDocument = strDocument & vbCrLf
            Next fld
        End If
    Next rel

    If Not IsMissing(varDebug) Then
        Debug.Print strDocument
    End If
    Print #1, strDocument
    
    aeDocumentRelations = True

PROC_EXIT:
    Set prop = Nothing
    Set idx = Nothing
    Set fld = Nothing
    Set rel = Nothing
    Close 1
    Exit Function

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeDocumentRelations of Class aegit_impClass", vbCritical, aeAPP_NAME
    If Not IsMissing(varDebug) Then Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeDocumentRelations of Class aegit_impClass"
    aeDocumentRelations = False
    Resume PROC_EXIT

End Function

Private Sub KillProperly(ByVal Killfile As String)
' Ref: http://word.mvps.org/faqs/macrosvba/DeleteFiles.htm

    On Error GoTo PROC_ERR

TryAgain:
    If Len(Dir$(Killfile)) > 0 Then
        SetAttr Killfile, vbNormal
        Kill Killfile
    End If

PROC_EXIT:
    Exit Sub

PROC_ERR:
    If Err = 70 Or Err = 75 Then
        Pause (0.25)
        Resume TryAgain
    End If
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " Killfile=" & Killfile & " (" & Err.Description & ") in procedure KillProperly of Class aegit_impClass", vbCritical, aeAPP_NAME
    Resume PROC_EXIT

End Sub

Private Function IsFileLocked(ByVal PathFileName As String) As Boolean
' Ref: http://accessexperts.com/blog/2012/03/06/checking-if-files-are-locked/

    'Debug.Print "IsFileLocked Entry PathFileName=" & PathFileName

    On Error GoTo PROC_ERR

    Dim i As Integer

    'Debug.Print , Len(Dir$(PathFileName))
    If Len(Dir$(PathFileName)) Then
        i = FreeFile()
        Open PathFileName For Random Access Read Write Lock Read Write As #i
        Lock i 'Redundant but let's be 100% sure
        Unlock i
        Close i
    Else
        'Err.Raise 53
    End If

PROC_EXIT:
    On Error GoTo 0
    Exit Function

PROC_ERR:
    Select Case Err.Number
        Case 70 'Unable to acquire exclusive lock
            MsgBox "A:Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure IsFileLocked of Class aegit_impClass", vbCritical, aeAPP_NAME
            IsFileLocked = True
        Case 9
            MsgBox "B:Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure IsFileLocked of Class aegit_impClass" & _
                    vbCrLf & "IsFileLocked Entry PathFileName=" & PathFileName, vbCritical, "ERROR=9"
            IsFileLocked = False
            'Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure IsFileLocked of Class aegit_impClass"
            Resume PROC_EXIT
        Case Else
            MsgBox "C:Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure IsFileLocked of Class aegit_impClass", vbCritical, aeAPP_NAME
            'Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure IsFileLocked of Class aegit_impClass"
            Resume PROC_EXIT
    End Select
    Resume

End Function

Private Function FolderExists(ByVal strPath As String) As Boolean
' Ref: http://allenbrowne.com/func-11.html
    On Error Resume Next
    FolderExists = ((GetAttr(strPath) And vbDirectory) = vbDirectory)
End Function

Private Function BuildTheDirectory(ByVal fso As Object, _
                                        Optional ByVal varDebug As Variant) As Boolean
'Private Function BuildTheDirectory(FSO As Scripting.FileSystemObject, _
                                        Optional varDebug As Variant) As Boolean
'*** Requires reference to "Microsoft Scripting Runtime"
'
' Ref: http://msdn.microsoft.com/en-us/library/ebkhfaaz(v=vs.85).aspx
'=======================================================================
' Author:   Peter F. Ennis
' Date:     February 8, 2011
' Comment:  Add optional debug parameter
' Requires: Reference to Microsoft Scripting Runtime
' Updated:  All notes moved to change log
' History:  See comment details, basChangeLog, commit messages on github
'=======================================================================

    Dim objImportFolder As Object

    On Error GoTo PROC_ERR

    Debug.Print "BuildTheDirectory"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so blnDebug of BuildTheDirectory is set to False"
        Debug.Print , "DEBUGGING IS OFF"
    Else
        Debug.Print , "varDebug IS NOT missing so blnDebug of BuildTheDirectory is set to True"
        Debug.Print , "NOW DEBUGGING..."
    End If

    If Not IsMissing(varDebug) Then Debug.Print , ">==> BuildTheDirectory >==>"

    ' Bail out if (a) the drive does not exist, or if (b) the directory already exists.

    If Not IsMissing(varDebug) Then Debug.Print , , "THE_DRIVE = " & THE_DRIVE
    If Not IsMissing(varDebug) Then Debug.Print , , "FSO.DriveExists(THE_DRIVE) = " & fso.DriveExists(THE_DRIVE)
    If Not fso.DriveExists(THE_DRIVE) Then
        If Not IsMissing(varDebug) Then Debug.Print , , "FSO.DriveExists(THE_DRIVE) = FALSE - The drive DOES NOT EXIST !!!"
        BuildTheDirectory = False
        Exit Function
    End If
    If Not IsMissing(varDebug) Then Debug.Print , , "The drive EXISTS !!!"
    
    If aegitImportFolder = "default" Then
        aestrImportLocation = aegitType.ImportFolder
    End If
        
    If Not IsMissing(varDebug) Then Debug.Print , , "The import directory is: " & aestrImportLocation
   
    If fso.FolderExists(aestrImportLocation) Then
        If Not IsMissing(varDebug) Then Debug.Print , , "FSO.FolderExists(aestrImportLocation) = TRUE - The directory EXISTS !!!"
        BuildTheDirectory = False
        Exit Function
    End If
    If Not IsMissing(varDebug) Then Debug.Print , , "The import directory does NOT EXIST !!!"

    BuildTheDirectory = True

PROC_EXIT:
    Set objImportFolder = Nothing
    Exit Function

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure BuildTheDirectory of Class aegit_impClass", vbCritical, aeAPP_NAME
    If Not IsMissing(varDebug) Then Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure BuildTheDirectory of Class aegit_impClass"
    BuildTheDirectory = False
    Resume PROC_EXIT

End Function

Private Function aeReadDocDatabase(ByVal blnImport As Boolean, Optional ByVal varDebug As Variant) As Boolean
' VBScript makes use of ADOX (Microsoft's Active Data Objects Extensions for Data Definition Language and Security)
' to create a query on a Microsoft Access database
' Ref: http://stackoverflow.com/questions/859530/alternative-to-application-loadfromtext-for-ms-access-queries
' Microsoft Access Stored Queries and VBscript: How to Create and Edit a Stored Database Query
' Ref: http://www.suite101.com/content/microsoft-access-stored-queries-and-vbscript-a87978#ixzz1D32Vqbso
' Using WScript
' Ref: http://www.codeforexcelandoutlook.com/vba/shell-scripting-using-vba-and-the-windows-script-host-object-model/
' vbscript get file extension
' Ref: http://www.experts-exchange.com/Programming/Languages/Visual_Basic/Q_24297896.html
'
'=======================================================================
' Author:   Peter F. Ennis
' Date:     February 8, 2011
' Comment:  Add explicit references for objects, wscript, fso
' Requires: Reference to Microsoft Scripting Runtime
' Updated:  All notes moved to change log
' History:  See comment details, basChangeLog, commit messages on github
'=======================================================================

    Dim MyFile As Object
    Dim strFileType As String
    Dim strFileBaseName As String
    Dim bln As Boolean

    On Error GoTo PROC_ERR

    Debug.Print "aeReadDocDatabase"
    If IsMissing(varDebug) Then
        Debug.Print , "varDebug IS missing so blnDebug of aeReadDocDatabase is set to False"
        Debug.Print , "DEBUGGING IS OFF"
    Else
        Debug.Print , "varDebug IS NOT missing so blnDebug of aeReadDocDatabase is set to True"
        Debug.Print , "NOW DEBUGGING..."
    End If

    If Not blnImport Then
        Debug.Print , "blnImport IS FALSE so exit aeReadDocDatabase"
        aeReadDocDatabase = False
        Exit Function
    End If
    
    Const acQuery As Integer = 1

    If aegitImportFolder = "default" Then
        aestrImportLocation = aegitType.ImportFolder
    Else
        aestrImportLocation = aegitImportFolder
    End If

    If Not IsMissing(varDebug) Then
        Debug.Print ">==> aeReadDocDatabase >==>"
        Debug.Print , "aegit VERSION: " & aegit_impVERSION
        Debug.Print , "aegit VERSION_DATE: " & aegit_impVERSION_DATE
        Debug.Print , "ImportFolder = " & aestrImportLocation
        'Stop
    End If

    ' Create needed objects
    Dim wsh As Object  ' As Object if late-bound
    Set wsh = CreateObject("WScript.Shell")

    If Not FolderExists(aestrImportLocation) Then
        MsgBox "The Import folder does not exist!" & vbCrLf & _
            "aestrImportLocation=" & aestrImportLocation, vbCritical, aeAPP_NAME
        Stop
    Else
        wsh.CurrentDirectory = aestrImportLocation
    End If

    If Not IsMissing(varDebug) Then Debug.Print , "wsh.CurrentDirectory = " & wsh.CurrentDirectory
    ' CurDir Function
    If Not IsMissing(varDebug) Then Debug.Print , "CurDir = " & CurDir

    ' Create needed objects
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")

    If Not IsMissing(varDebug) Then
        bln = BuildTheDirectory(fso, "WithDebugging")
        Debug.Print , "<==<"
    Else
        bln = BuildTheDirectory(fso)
    End If

    Dim objFolder As Object
    Set objFolder = fso.GetFolder(aestrImportLocation)

    For Each MyFile In objFolder.Files
        If Not IsMissing(varDebug) Then Debug.Print "myFile = " & MyFile
        If Not IsMissing(varDebug) Then Debug.Print "myFile.Name = " & MyFile.Name
        strFileBaseName = fso.GetBaseName(MyFile.Name)
        strFileType = fso.GetExtensionName(MyFile.Name)
        If Not IsMissing(varDebug) Then Debug.Print strFileBaseName & " (" & strFileType & ")"

        If (strFileType = "frm") Then
            If Exists("FORMS", strFileBaseName) Then
                MsgBox "Skipping: FORM " & strFileBaseName & " exists in the current database.", vbInformation, "EXISTENCE IS REAL !!!"
                If Not IsMissing(varDebug) Then Debug.Print "Skipping: FORM " & strFileBaseName & " exists in the current database.", "EXISTENCE IS REAL !!!"
            Else
                Application.LoadFromText acForm, strFileBaseName, MyFile.Path
            End If
        ElseIf (strFileType = "rpt") Then
            If Exists("REPORTS", strFileBaseName) Then
                MsgBox "Skipping: REPORT " & strFileBaseName & " exists in the current database.", vbInformation, "EXISTENCE IS REAL !!!"
                If Not IsMissing(varDebug) Then Debug.Print "Skipping: REPORT " & strFileBaseName & " exists in the current database.", "EXISTENCE IS REAL !!!"
            Else
                Application.LoadFromText acReport, strFileBaseName, MyFile.Path
            End If
        ElseIf (strFileType = "bas") Then
            If Exists("MODULES", strFileBaseName) Then
                MsgBox "Skipping: MODULE " & strFileBaseName & " exists in the current database.", vbInformation, "EXISTENCE IS REAL !!!"
                If Not IsMissing(varDebug) Then Debug.Print "Skipping: MODULE " & strFileBaseName & " exists in the current database.", "EXISTENCE IS REAL !!!"
            Else
                Application.LoadFromText acModule, strFileBaseName, MyFile.Path
            End If
        ElseIf (strFileType = "mac") Then
            If Exists("MACROS", strFileBaseName) Then
                MsgBox "Skipping: MACRO " & strFileBaseName & " exists in the current database.", vbInformation, "EXISTENCE IS REAL !!!"
                If Not IsMissing(varDebug) Then Debug.Print "Skipping: MACRO " & strFileBaseName & " exists in the current database.", "EXISTENCE IS REAL !!!"
            Else
                Application.LoadFromText acMacro, strFileBaseName, MyFile.Path
            End If
        ElseIf (strFileType = "qry") Then
            If Exists("QUERIES", strFileBaseName) Then
                MsgBox "Skipping: QUERY " & strFileBaseName & " exists in the current database.", vbInformation, "EXISTENCE IS REAL !!!"
                If Not IsMissing(varDebug) Then Debug.Print "Skipping: QUERY " & strFileBaseName & " exists in the current database.", "EXISTENCE IS REAL !!!"
            Else
                Application.LoadFromText acQuery, strFileBaseName, MyFile.Path
            End If
        End If
    Next

    If Not IsMissing(varDebug) Then Debug.Print "<==<"
    
    aeReadDocDatabase = True

PROC_EXIT:
    Set MyFile = Nothing
    Set fso = Nothing
    Set wsh = Nothing
    aeReadDocDatabase = True
    Exit Function

PROC_ERR:
    MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeReadDocDatabase of Class aegit_impClass", vbCritical, aeAPP_NAME
    If Not IsMissing(varDebug) Then Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeReadDocDatabase of Class aegit_impClass"
    aeReadDocDatabase = False
    Resume PROC_EXIT

End Function

Private Function aeExists(ByVal strAccObjType As String, _
                        ByVal strAccObjName As String, Optional ByVal varDebug As Variant) As Boolean
' Ref: http://vbabuff.blogspot.com/2010/03/does-access-object-exists.html
'
'=======================================================================
' Author:     Peter F. Ennis
' Date:       February 18, 2011
' Comment:    Return True if the object exists
' Parameters:
'             strAccObjType: "Tables", "Queries", "Forms",
'                            "Reports", "Macros", "Modules"
'             strAccObjName: The name of the object
' Updated:  All notes moved to change log
' History:  See comment details, basChangeLog, commit messages on github
'=======================================================================

    Dim objType As Object
    Dim obj As Variant
    Dim blnDebug As Boolean
    
    On Error GoTo PROC_ERR

    Debug.Print "aeExists"
    If IsMissing(varDebug) Then
        blnDebug = False
        Debug.Print , "varDebug IS missing so blnDebug of aeExists is set to False"
        Debug.Print , "DEBUGGING IS OFF"
    Else
        blnDebug = True
        Debug.Print , "varDebug IS NOT missing so blnDebug of aeExists is set to True"
        Debug.Print , "NOW DEBUGGING..."
    End If

    If Not IsMissing(varDebug) Then Debug.Print ">==> aeExists >==>"

    Select Case strAccObjType
        Case "Tables"
            Set objType = CurrentDb.TableDefs
        Case "Queries"
            Set objType = CurrentDb.QueryDefs
        Case "Forms"
            Set objType = CurrentProject.AllForms
        Case "Reports"
            Set objType = CurrentProject.AllReports
        Case "Macros"
            Set objType = CurrentProject.AllMacros
        Case "Modules"
            Set objType = CurrentProject.AllModules
        Case Else
            MsgBox "Wrong option!", vbCritical, "in procedure aeExists of Class aegit_impClass"
            If Not IsMissing(varDebug) Then
                Debug.Print , "strAccObjType = >" & strAccObjType & "< is  a false value"
                Debug.Print , "Option allowed is one of 'Tables', 'Queries', 'Forms', 'Reports', 'Macros', 'Modules'"
                Debug.Print "<==<"
            End If
            aeExists = False
            Set obj = Nothing
            Exit Function
    End Select

    If Not IsMissing(varDebug) Then Debug.Print , "strAccObjType = " & strAccObjType
    If Not IsMissing(varDebug) Then Debug.Print , "strAccObjName = " & strAccObjName

    For Each obj In objType
        If Not IsMissing(varDebug) Then Debug.Print , obj.Name, strAccObjName
        If obj.Name = strAccObjName Then
            If Not IsMissing(varDebug) Then
                Debug.Print , strAccObjName & " EXISTS!"
                Debug.Print "<==<"
            End If
            aeExists = True
            Set obj = Nothing
            Exit Function ' Found it!
        Else
            aeExists = False
        End If
    Next
    If Not IsMissing(varDebug) And aeExists = False Then
        Debug.Print , strAccObjName & " DOES NOT EXIST!"
        Debug.Print "<==<"
    End If

PROC_EXIT:
    Set obj = Nothing
    Exit Function

PROC_ERR:
    If Err = 3011 Then
        aeExists = False
        Resume PROC_EXIT
    Else
        MsgBox "Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeExists of Class aegit_impClass", vbCritical, aeAPP_NAME
        If Not IsMissing(varDebug) Then Debug.Print ">>>Erl=" & Erl & " Error " & Err.Number & " (" & Err.Description & ") in procedure aeExists of Class aegit_impClass"
        aeExists = False
    End If
    Resume PROC_EXIT

End Function

Private Function GetType(ByVal Value As Long) As String
' Ref: http://bytes.com/topic/access/answers/557780-getting-string-name-enum

    On Error GoTo 0
    Select Case Value
        Case acCheckBox
            GetType = "CheckBox"
        Case acTextBox
            GetType = "TextBox"
        Case acListBox
            GetType = "ListBox"
        Case acComboBox
            GetType = "ComboBox"
        Case Else
    End Select

End Function

Private Function fListGUID(ByVal strTableName As String) As String
' Ref: http://stackoverflow.com/questions/8237914/how-to-get-the-guid-of-a-table-in-microsoft-access
' e.g. ?fListGUID("tblThisTableHasSomeReallyLongNameButItCouldBeMuchLonger")

    On Error GoTo 0
    Dim i As Integer
    Dim arrGUID8() As Byte
    Dim strArrGUID8(8) As String
    Dim strGuid As String

    strGuid = vbNullString
    arrGUID8 = CurrentDb.TableDefs(strTableName).Properties("GUID").Value
    For i = 1 To 8
        If Len(Hex$(arrGUID8(i))) = 1 Then
            strArrGUID8(i) = "0" & Hex$(arrGUID8(i))
        Else
            strArrGUID8(i) = Hex$(arrGUID8(i))
        End If
    Next

    For i = 1 To 8
        strGuid = strGuid & strArrGUID8(i) & "-"
    Next
    fListGUID = Left$(strGuid, 23)

End Function

'==================================================
' Global Error Handler Routines
' Ref: http://msdn.microsoft.com/en-us/library/office/ee358847(v=office.12).aspx#odc_ac2007_ta_ErrorHandlingAndDebuggingTipsForAccessVBAndVBA_WritingCodeForDebugging
'==================================================

Private Sub WriteErrorToFile(ByVal intTheErl As Integer, ByVal lngTheErrorNum As Long, _
                ByVal strCurrentProcName As String, ByVal strErrorDescription As String)
    
    Dim strFilePath As String
    Dim lngFileNum As Long
    
    On Error Resume Next

    ' Write to a text file called aegitErrorLog in the MyDocuments folder
    strFilePath = CreateObject("WScript.Shell").SpecialFolders("MYDOCUMENTS") & "\aegitErrorLog.txt"

    lngFileNum = FreeFile
    Open strFilePath For Append Access Write Lock Write As lngFileNum
        Print #lngFileNum, Now(), intTheErl, lngTheErrorNum, strCurrentProcName, strErrorDescription
    Close lngFileNum

End Sub

Private Sub WriteStringToFile(ByVal lngFileNum As Long, ByVal strTheString As String, ByVal strTheAbsoluteFileName As String)
  
    On Error Resume Next

    Open strTheAbsoluteFileName For Append Access Write Lock Write As lngFileNum
        Print #lngFileNum, strTheString
    Close lngFileNum

End Sub