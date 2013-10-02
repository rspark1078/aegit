Option Compare Database
Option Explicit

' Remove this after integration with aegitClass
Public Const THE_SOURCE_FOLDER = "C:\ae\aegit\aerc\src\"

Public Sub TestCreateDbScript()
    'CreateDbScript "C:\Temp\Schema.txt"
    Debug.Print "THE_SOURCE_FOLDER=" & THE_SOURCE_FOLDER
    CreateDbScript THE_SOURCE_FOLDER & "Schema.txt"
End Sub

Public Sub CreateDbScript(strScriptFile As String)
' Remou - Ref: http://stackoverflow.com/questions/698839/how-to-extract-the-schema-of-an-access-mdb-database/9910716#9910716

    Dim db As DAO.Database
    Dim tdf As DAO.TableDef
    Dim fld As DAO.Field
    Dim ndx As DAO.Index
    Dim strSQL As String
    Dim strFlds As String
    Dim strCn As String
    Dim strLinkedTablePath As String
    Dim fs As Object
    Dim f As Object

    Set db = CurrentDb
    Set fs = CreateObject("Scripting.FileSystemObject")
    Set f = fs.CreateTextFile(strScriptFile)

    strSQL = "Public Sub CreateTheDb()" & vbCrLf
    f.WriteLine strSQL
    strSQL = "Dim strSQL As String"
    f.WriteLine strSQL
    strSQL = "On Error GoTo ErrorTrap"
    f.WriteLine strSQL

    For Each tdf In db.TableDefs
        If Not (Left(tdf.Name, 4) = "MSys" _
                Or Left(tdf.Name, 4) = "~TMP" _
                Or Left(tdf.Name, 3) = "zzz") Then

            strLinkedTablePath = GetLinkedTableCurrentPath(tdf.Name)
            If strLinkedTablePath <> "" Then
                f.WriteLine vbCrLf & "'OriginalLink=>" & strLinkedTablePath
            Else
                f.WriteLine vbCrLf & "'Local Table"
            End If

            strSQL = "strSQL=""CREATE TABLE [" & tdf.Name & "] ("
            strFlds = ""

            For Each fld In tdf.Fields

                strFlds = strFlds & ",[" & fld.Name & "] "

                Select Case fld.Type
                    Case dbText
                        'No look-up fields
                        strFlds = strFlds & "Text (" & fld.Size & ")"
                    Case dbLong
                        If (fld.Attributes And dbAutoIncrField) = 0& Then
                            strFlds = strFlds & "Long"
                        Else
                            strFlds = strFlds & "Counter"
                        End If
                    Case dbBoolean
                        strFlds = strFlds & "YesNo"
                    Case dbByte
                        strFlds = strFlds & "Byte"
                    Case dbInteger
                        strFlds = strFlds & "Integer"
                    Case dbCurrency
                        strFlds = strFlds & "Currency"
                    Case dbSingle
                        strFlds = strFlds & "Single"
                    Case dbDouble
                        strFlds = strFlds & "Double"
                    Case dbDate
                        strFlds = strFlds & "DateTime"
                    Case dbBinary
                        strFlds = strFlds & "Binary"
                    Case dbLongBinary
                        strFlds = strFlds & "OLE Object"
                    Case dbMemo
                        If (fld.Attributes And dbHyperlinkField) = 0& Then
                            strFlds = strFlds & "Memo"
                        Else
                            strFlds = strFlds & "Hyperlink"
                        End If
                    Case dbGUID
                        strFlds = strFlds & "GUID"
                End Select

            Next

            strSQL = strSQL & Mid(strFlds, 2) & " )""" & vbCrLf & "Currentdb.Execute strSQL"
            f.WriteLine vbCrLf & strSQL

            'Indexes
            For Each ndx In tdf.Indexes

                If ndx.Unique Then
                    strSQL = "strSQL=""CREATE UNIQUE INDEX "
                Else
                    strSQL = "strSQL=""CREATE INDEX "
                End If

                strSQL = strSQL & "[" & ndx.Name & "] ON [" & tdf.Name & "] ("
                strFlds = ""

                For Each fld In tdf.Fields
                    strFlds = ",[" & fld.Name & "]"
                Next

                strSQL = strSQL & Mid(strFlds, 2) & ") "
                strCn = ""

                If ndx.Primary Then
                    strCn = " PRIMARY"
                End If

                If ndx.Required Then
                    strCn = strCn & " DISALLOW NULL"
                End If

                If ndx.IgnoreNulls Then
                    strCn = strCn & " IGNORE NULL"
                End If

                If Trim(strCn) <> vbNullString Then
                    strSQL = strSQL & " WITH" & strCn & " "
                End If

                f.WriteLine vbCrLf & strSQL & """" & vbCrLf & "Currentdb.Execute strSQL"
            Next
        End If
    Next

    'strSQL = vbCrLf & "Debug.Print " & """" & "Done" & """"
    'f.WriteLine strSQL
    f.WriteLine
    f.WriteLine "'Access 2010 - Compact And Repair"
    strSQL = "SendKeys " & """" & "%F{END}{ENTER}%F{TAB}{TAB}{ENTER}" & """" & ", False"
    f.WriteLine strSQL
    strSQL = "Exit Sub"
    f.WriteLine strSQL
    strSQL = "ErrorTrap:"
    f.WriteLine strSQL
    'MsgBox "Erl=" & Erl & vbCrLf & "Err.Number=" & Err.Number & vbCrLf & "Err.Description=" & Err.Description
    strSQL = "MsgBox " & """" & "Erl=" & """" & " & vbCrLf & " & _
                """" & "Err.Number=" & """" & " & Err.Number & vbCrLf & " & _
                """" & "Err.Description=" & """" & " & Err.Description"
    f.WriteLine strSQL & vbCrLf
    strSQL = "End Sub"
    f.WriteLine strSQL

    f.Close
    Debug.Print "Done"

End Sub

Public Function GetLinkedTableCurrentPath(MyLinkedTable As String) As String
' Ref: http://www.access-programmers.co.uk/forums/showthread.php?t=198057
' To test in the Immediate window:       ? getcurrentpath("Const")
'====================================================================
' Procedure : GetLinkedTableCurrentPath
' DateTime  : 08/23/2010
' Author    : Rx
' Purpose   : Returns Current Path of a Linked Table in Access
' Updates   : Peter F. Ennis
' Updated   : All notes moved to change log
' History   : See comment details, basChangeLog, commit messages on github
'====================================================================
    On Error GoTo PROC_ERR
    GetLinkedTableCurrentPath = Mid(CurrentDb.TableDefs(MyLinkedTable).Connect, InStr(1, CurrentDb.TableDefs(MyLinkedTable).Connect, "=") + 1)
        ' non-linked table returns blank - the Instr removes the "Database="

PROC_EXIT:
    On Error Resume Next
    Exit Function

PROC_ERR:
    Select Case Err.Number
        'Case ###         ' Add your own error management or log error to logging table
        Case Else
            'a custom log usage function commented out
            'function LogUsage(ByVal strFormName As String, strCallingProc As String, Optional ControlName) As Boolean
            'call LogUsage Err.Number, "basRelinkTables", "GetCurrentPath" ()
    End Select
    Resume PROC_EXIT
End Function

' Ref: http://www.utteraccess.com/forum/lofiversion/index.php/t1995627.html
'-------------------------------------------------------------------------------------------------
' Procedure : ExecSQL
' DateTime  : 30/03/2009 10:19
' Author    : Dial222
' Purpose   : Execute SQL Select statements in the Immediate window
' Context   : Module basSQL2IMM
' Notes     : No error trapping whatsover - this is a 1.0 technology!
'             Max out at 194 data rows since immediate only displays 100!
'
' Usage     : in the immediate pane: ?execsql("select * from zstblprofile","|")
'
' Revision History
' Version   Date        Who             What
' 01        30/03/2009  Dial222         Function 'ExecSQL' Created
' 02        30/03/2009  Dial222         Added code for left/right align of text/numeric data
'                                       Added MaxRowLen and vbCrLF parsing functionality
'                                       Uprated cMaxRows to 194
'-------------------------------------------------------------------------------------------------
'

Public Function ExecSQL(strSQL As String, Optional strColumDelim As String = "|") As Boolean

    Dim rs              As DAO.Recordset
    Dim aintLen()       As Integer
    Dim i               As Integer
    Dim str             As String
    Dim lngRowCOunt     As Long

    Const cMaxRows      As Integer = 194
    Const cMaxRowLen    As Integer = 1023  ' Max width of immediate pane in characters, truncate after this.

    Set rs = CurrentDb.OpenRecordset(strSQL, dbOpenDynaset, dbSeeChanges)

    With rs
        .MoveLast
        .MoveFirst

        lngRowCOunt = .RecordCount
        If lngRowCOunt > 0 Then
            If lngRowCOunt > cMaxRows Then
                Debug.Print "Too many rows to return, will only print first " & cMaxRows & " rows."
            End If

            ReDim Preserve aintLen(.Fields.Count)

            For i = 0 To .Fields.Count - 1
                ' Initialise field len to field name len
                aintLen(i) = Len(.Fields(i).Name) + 3
            Next i

            ' On this pass just get length of field data for formatting
            Do Until .EOF
                If .AbsolutePosition = cMaxRows Then
                    ' Stop at the magic number
                    Exit Do
                Else
                    For i = 0 To rs.Fields.Count - 1
                        ' Test and update field len
                        If Len(CStr(Nz(.Fields(i).Value, ""))) > aintLen(i) Then
                            aintLen(i) = Len(CStr(.Fields(i).Value)) + 3
                        End If
                    Next i
                End If
                .MoveNext
            Loop

            ' Print Column Headers
            str = "Row " & strColumDelim & " "
            For i = 0 To rs.Fields.Count - 1
                ' Initialise field len to field name len
                str = str & Left(.Fields(i).Name & Space(aintLen(i)), aintLen(i)) & " " & strColumDelim & " "
            Next i

            ' Print the header row
            Debug.Print Left(str, cMaxRowLen)
            str = Space(Len(str))
            str = Replace(str, " ", "-")

            ' print underscores
            Debug.Print Left(str, cMaxRowLen)
            str = ""

            ' Start over for the data
            .MoveFirst

            Do Until .EOF
                If .AbsolutePosition = cMaxRows Then
                    Exit Do
                Else
                    str = Left(.AbsolutePosition + 1 & Space(3), 3) & " " & strColumDelim & " "
                    For i = 0 To .Fields.Count - 1
                        Select Case .Fields(i).Type
                            Case Is = 3, 4, 5, 6, 7, 8, 16, 19, 20, 21, 22, 23 ' The numeric DataTypeEnums
                                str = str & Right(Space(aintLen(i)) & .Fields(i).Value, aintLen(i)) & " " & strColumDelim & " "
                            Case Else
                                ' Is it number stored as text
                                If IsNumeric(.Fields(i).Value) Then
                                    ' Right align
                                    str = str & Right(Space(aintLen(i)) & .Fields(i).Value, aintLen(i)) & " " & strColumDelim & " "
                                Else
                                    ' Left align
                                    str = str & Left(.Fields(i).Value & Space(aintLen(i)), aintLen(i)) & " " & strColumDelim & " "
                                End If
                        End Select
                    Next i
                End If

                ' Parse out vbCrLf and dump data row to immediate
                Debug.Print Left(Replace(Replace(str, Chr(13), " "), Chr(10), " "), cMaxRowLen)
                .MoveNext
                str = ""
            Loop

            ExecSQL = True
        Else
            Debug.Print "No rows returned"
        End If
    End With

    Set rs = Nothing

End Function

Public Function SpFolder(SpName)

    Dim objShell As Object
    Dim objFolder As Object
    Dim objFolderItem As Object

    Set objShell = CreateObject("Shell.Application")
    Set objFolder = objShell.Namespace(SpName)

    Set objFolderItem = objFolder.Self

    SpFolder = objFolderItem.Path

End Function
   
Public Sub AllCodeToDesktop()
' Ref: http://wiki.lessthandot.com/index.php/Code_and_Code_Windows
' Ref: http://stackoverflow.com/questions/2794480/exporting-code-from-microsoft-access
' The reference for the FileSystemObject Object is Windows Script Host Object Model
' but it not necessary to add the reference for this procedure.

    Const Desktop = &H10&
    Const MyDocuments = &H5&

    Dim fs As Object
    Dim f As Object
    Dim strMod As String
    Dim mdl As Object
    Dim i As Integer
    Dim strTxtFile As String

    Set fs = CreateObject("Scripting.FileSystemObject")

    'Set up the file
    Debug.Print "CurrentProject.Name = " & CurrentProject.Name
    strTxtFile = SpFolder(Desktop) & "\" & Replace(CurrentProject.Name, ".", " ") & ".txt"
    Debug.Print "strTxtFile = " & strTxtFile
    Set f = fs.CreateTextFile(SpFolder(Desktop) & "\" _
        & Replace(CurrentProject.Name, ".", " ") & ".txt")

    'For each component in the project ...
    For Each mdl In VBE.ActiveVBProject.VBComponents
        'using the count of lines ...
        i = VBE.ActiveVBProject.VBComponents(mdl.Name).codemodule.CountOfLines
        'put the code in a string ...
        If i > 0 Then
            strMod = VBE.ActiveVBProject.VBComponents(mdl.Name).codemodule.Lines(1, i)
        End If
        'and then write it to a file, first marking the start with
        'some equal signs and the component name.
        f.WriteLine String(15, "=") & vbCrLf & mdl.Name _
            & vbCrLf & String(15, "=") & vbCrLf & strMod
    Next
       
    'Close eveything
    f.Close
    Set fs = Nothing

End Sub

Public Function PropertyExists(obj As Object, strPropertyName As String) As Boolean
' Ref: http://www.utteraccess.com/forum/Description-property-Mic-t552348.html
' e.g. ? PropertyExists(CurrentDB. ("The Name Of Your Table"), "Description")
    Dim var As Variant

    On Error Resume Next
    Set var = obj.Properties(strPropertyName)
    If Err.Number > 0 Then
        PropertyExists = False
    Else
        PropertyExists = True
    End If

End Function

Public Sub GetPropertyDescription()
' Ref: http://www.dbforums.com/microsoft-access/1620765-read-ms-access-table-properties-using-vba.html

    Dim dbs As DAO.Database
    Dim obj As Object
    Dim prp As Property

    Set dbs = Application.CurrentDb
    Set obj = dbs.Containers("modules").Documents("aegitClass")

    On Error Resume Next
    For Each prp In obj.Properties
        Debug.Print prp.Name, prp.Value
    Next prp

    Set obj = Nothing
    Set dbs = Nothing

End Sub

Public Sub TestListAllProperties()
    'ListAllProperties ("modules")
    ListAllProperties ("tables")
End Sub

Public Sub ListGUID()
' Ref: http://stackoverflow.com/questions/8237914/how-to-get-the-guid-of-a-table-in-microsoft-access

    Dim i As Integer
    Dim arrGUID8() As Byte
    Dim strGUID As String

    arrGUID8 = CurrentDb.TableDefs("tblThisTableHasSomeReallyLongNameButItCouldBeMuchLonger").Properties("GUID").Value
    For i = 1 To 8
        strGUID = strGUID & Hex(arrGUID8(i)) & "-"
    Next
    Debug.Print Left(strGUID, 23)

End Sub

Public Function fListGUID(strTableName As String) As String
' Ref: http://stackoverflow.com/questions/8237914/how-to-get-the-guid-of-a-table-in-microsoft-access
' e.g. ?fListGUID("tblThisTableHasSomeReallyLongNameButItCouldBeMuchLonger")

    Dim i As Integer
    Dim arrGUID8() As Byte
    Dim strGUID As String

    arrGUID8 = CurrentDb.TableDefs(strTableName).Properties("GUID").Value
    For i = 1 To 8
        strGUID = strGUID & Hex(arrGUID8(i)) & "-"
    Next
    'Debug.Print Left(strGUID, 23)
    fListGUID = Left(strGUID, 23)

End Function

Public Sub ListAllProperties(strContainer As String)
' Ref: http://www.dbforums.com/microsoft-access/1620765-read-ms-access-table-properties-using-vba.html
' Ref: http://ms-access.veryhelper.com/q_ms-access-database_153855.html
' Ref: http://msdn.microsoft.com/en-us/library/office/aa139941(v=office.10).aspx
    
    Dim dbs As DAO.Database
    Dim obj As Object
    Dim prp As Property
    Dim doc As Document

    Set dbs = Application.CurrentDb
    Set obj = dbs.Containers(strContainer)

    'Debug.Print "Modules", obj.Documents.Count
    'Debug.Print "Modules", obj.Documents(1).Name
    'Debug.Print "Modules", obj.Documents(2).Name

    ' Ref: http://stackoverflow.com/questions/16642362/how-to-get-the-following-code-to-continue-on-error
    For Each doc In obj.Documents
        If Left(doc.Name, 4) <> "MSys" And Left(doc.Name, 3) <> "zzz" Then
            Debug.Print ">>>" & doc.Name
            For Each prp In doc.Properties
                On Error Resume Next
                    If prp.Name = "GUID" And strContainer = "tables" Then
                        Debug.Print prp.Name, fListGUID(doc.Name)
                    ElseIf prp.Name = "DOL" Then
                        Debug.Print prp.Name, "Track name AutoCorrect info is ON!"
                    ElseIf prp.Name = "NameMap" Then
                        Debug.Print prp.Name, "Track name AutoCorrect info is ON!"
                    Else
                        Debug.Print prp.Name, prp.Value
                    End If
                On Error GoTo 0
            Next
        End If
    Next

    Set obj = Nothing
    Set dbs = Nothing

End Sub

Public Sub TestPropertiesOutput()
' Ref: http://www.everythingaccess.com/tutorials.asp?ID=Accessing-detailed-file-information-provided-by-the-Operating-System
' Ref: http://www.techrepublic.com/article/a-simple-solution-for-tracking-changes-to-access-data/
' Ref: http://social.msdn.microsoft.com/Forums/office/en-US/480c17b3-e3d1-4f98-b1d6-fa16b23c6a0d/please-help-to-edit-the-table-query-form-and-modules-modified-date
'
' Ref: http://perfectparadigm.com/tip001.html
'SELECT MSysObjects.DateCreate, MSysObjects.DateUpdate,
'MSysObjects.Name , MSysObjects.Type
'FROM MSysObjects;

    Debug.Print ">>>frm_Dummy"
    Debug.Print "DateCreated", DBEngine(0)(0).Containers("Forms")("frm_Dummy").Properties("DateCreated").Value
    Debug.Print "LastUpdated", DBEngine(0)(0).Containers("Forms")("frm_Dummy").Properties("LastUpdated").Value

' *** Ref: http://support.microsoft.com/default.aspx?scid=kb%3Ben-us%3B299554 ***
'When the user initially creates a new Microsoft Access specific-object, such as a form), the database engine still
'enters the current date and time into the DateCreate and DateUpdate columns in the MSysObjects table. However, when
'the user modifies and saves the object, Microsoft Access does not notify the database engine; therefore, the
'DateUpdate column always stays the same.

' Ref: http://questiontrack.com/how-can-i-display-a-last-modified-time-on-ms-access-form-995507.html

    Dim obj As AccessObject
    Dim dbs As Object

    Set dbs = Application.CurrentData
    Set obj = dbs.AllTables("tblThisTableHasSomeReallyLongNameButItCouldBeMuchLonger")
    Debug.Print ">>>" & obj.Name
    Debug.Print "DateCreated: " & obj.DateCreated
    Debug.Print "DateModified: " & obj.DateModified

End Sub

Public Sub ListAccessApplicationOptions()
' Note: If you are developing a database application, add-in, library database, or referenced database, make sure that the
' Error Trapping option is set to 2 (Break On Unhandled Errors) when you have finished debugging your code.
'
' Ref: http://msdn.microsoft.com/en-us/library/office/aa140020(v=office.10).aspx (2000)
' Ref: http://msdn.microsoft.com/en-us/library/office/aa189769(v=office.10).aspx (XP)
'   IME is Microsoft Global Input Method Editors (IMEs)
'   Ref: http://www.dbforums.com/microsoft-access/993286-what-ime.html
' Ref: http://msdn.microsoft.com/en-us/library/office/aa172326(v=office.11).aspx (2003)
' Ref: http://msdn.microsoft.com/en-us/library/office/bb256546(v=office.12).aspx (2007)
' Ref: http://msdn.microsoft.com/en-us/library/office/ff823177(v=office.14).aspx (2010)
' *** Ref: http://msdn.microsoft.com/en-us/library/office/ff823177.aspx (2013)
' Ref: http://office.microsoft.com/en-us/access-help/HV080750165.aspx (2013?)
' Set Options from Visual Basic

    Dim dbs As Database
    Set dbs = CurrentDb

    On Error Resume Next
    Debug.Print ">>>Standard Options"
    '2000 The following options are equivalent to the standard startup options found in the Startup Options dialog box.
    Debug.Print , "2000", "AppTitle", dbs.Properties!AppTitle                               'String  The title of an application, as displayed in the title bar.
    Debug.Print , "2000", "AppIcon", dbs.Properties!AppIcon                                 'String  The file name and path of an application's icon.
    Debug.Print , "2000", "StartupMenuBar", dbs.Properties!StartUpMenuBar                   'String  Sets the default menu bar for the application.
    Debug.Print , "2000", "AllowFullMenus", dbs.Properties!AllowFullMenus                   'True/False  Determines if the built-in Access menu bars are displayed.
    Debug.Print , "2000", "AllowShortcutMenus", dbs.Properties!AllowShortcutMenus           'True/False  Determines if the built-in Access shortcut menus are displayed.
    Debug.Print , "2000", "StartupForm", dbs.Properties!StartUpForm                         'String  Sets the form or data page to show when the application is first opened.
    Debug.Print , "2000", "StartupShowDBWindow", dbs.Properties!StartUpShowDBWindow         'True/False  Determines if the database window is displayed when the application is first opened.
    Debug.Print , "2000", "StartupShowStatusBar", dbs.Properties!StartUpShowStatusBar       'True/False  Determines if the status bar is displayed.
    Debug.Print , "2000", "StartupShortcutMenuBar", dbs.Properties!StartUpShortcutMenuBar   'String  Sets the shortcut menu bar to be used in all forms and reports.
    Debug.Print , "2000", "AllowBuiltInToolbars", dbs.Properties!AllowBuiltInToolbars       'True/False  Determines if the built-in Access toolbars are displayed.
    Debug.Print , "2000", "AllowToolbarChanges", dbs.Properties!AllowToolbarChanges         'True/False  Determined if toolbar changes can be made.
    Debug.Print ">>>Advanced Option"
    Debug.Print , "2000", "AllowSpecialKeys", dbs.Properties!AllowSpecialKeys               'option (True/False value) determines if the use of special keys is permitted. It is equivalent to the advanced startup option found in the Startup Options dialog box.
    Debug.Print ">>>Extra Options"
    'The following options are not available from the Startup Options dialog box or any other Access user interface component, they are only available in programming code.
    Debug.Print , "2000", "AllowBypassKey", dbs.Properties!AllowBypassKey                   'True/False  Determines if the SHIFT key can be used to bypass the application load process.
    Debug.Print , "2000", "AllowBreakIntoCode", dbs.Properties!AllowBreakIntoCode           'True/False  Determines if the CTRL+BREAK key combination can be used to stop code from running.
    Debug.Print , "2000", "HijriCalendar", dbs.Properties!HijriCalendar                     'True/False  Applies only to Arabic countries; determines if the application uses Hijri or Gregorian dates.
    Debug.Print ">>>View Tab"
    Debug.Print , "XP, 2003", "Show Status Bar", Application.GetOption("Show Status Bar")                                     'Show, Status bar
    Debug.Print , "XP, 2003", "Show Startup Dialog Box", Application.GetOption("Show Startup Dialog Box")                     'Show, Startup Task Pane
    Debug.Print , "XP, 2003", "Show New Object Shortcuts", Application.GetOption("Show New Object Shortcuts")                 'Show, New object shortcuts
    Debug.Print , "XP, 2003", "Show Hidden Objects", Application.GetOption("Show Hidden Objects")                             'Show, Hidden objects
    Debug.Print , "XP, 2003", "Show System Objects", Application.GetOption("Show System Objects")                             'Show, System objects
    Debug.Print , "XP, 2003", "ShowWindowsInTaskbar", Application.GetOption("ShowWindowsInTaskbar")                           'Show, Windows in Taskbar
    Debug.Print , "XP, 2003", "Show Macro Names Column", Application.GetOption("Show Macro Names Column")                     'Show in Macro Design, Names column
    Debug.Print , "XP, 2003", "Show Conditions Column", Application.GetOption("Show Conditions Column")                       'Show in Macro Design, Conditions column
    Debug.Print , "XP, 2003", "Database Explorer Click Behavior", Application.GetOption("Database Explorer Click Behavior")   'Click options in database window
    Debug.Print ">>>General Tab"
    Debug.Print , "XP, 2003", "Left Margin", Application.GetOption("Left Margin")                                                             'Print margins, Left margin
    Debug.Print , "XP, 2003", "Right Margin", Application.GetOption("Right Margin")                                                           'Print margins, Right margin
    Debug.Print , "XP, 2003", "Top Margin", Application.GetOption("Top Margin")                                                               'Print margins, Top margin
    Debug.Print , "XP, 2003", "Bottom Margin", Application.GetOption("Bottom Margin")                                                         'Print margins, Bottom margin
    Debug.Print , "XP, 2003", "Four-Digit Year Formatting", Application.GetOption("Four-Digit Year Formatting")                               'Use four-year digit year formatting, This database
    Debug.Print , "XP, 2003", "Four-Digit Year Formatting All Databases", Application.GetOption("Four-Digit Year Formatting All Databases")   'Use four-year digit year formatting, All databases  Four-Digit Year Formatting All Databases
    Debug.Print , "XP, 2003", "Track Name AutoCorrect Info", Application.GetOption("Track Name AutoCorrect Info")                             'Name AutoCorrect, Track name AutoCorrect info
    Debug.Print , "XP, 2003", "Perform Name AutoCorrect", Application.GetOption("Perform Name AutoCorrect")                                   'Name AutoCorrect, Perform name AutoCorrect
    Debug.Print , "XP, 2003", "Log Name AutoCorrect Changes", Application.GetOption("Log Name AutoCorrect Changes")                           'Name AutoCorrect, Log name AutoCorrect changes
    Debug.Print , "XP, 2003", "Enable MRU File List", Application.GetOption("Enable MRU File List")                                           'Recently used file list
    Debug.Print , "XP, 2003", "Size of MRU File List", Application.GetOption("Size of MRU File List")                                         'Recently used file list, (number of files)
    Debug.Print , "XP, 2003", "Provide Feedback with Sound", Application.GetOption("Provide Feedback with Sound")                             'Provide feedback with sound
    Debug.Print , "XP, 2003", "Auto Compact", Application.GetOption("Auto Compact")                                                           'Compact on Close
    Debug.Print , "XP, 2003", "New Database Sort Order", Application.GetOption("New Database Sort Order")                                     'New database sort order
    Debug.Print , "XP, 2003", "Remove Personal Information", Application.GetOption("Remove Personal Information")                             'Remove personal information from this file
    Debug.Print , "XP, 2003", "Default Database Directory", Application.GetOption("Default Database Directory")                               'Default database folder
    Debug.Print ">>>Edit/Find Tab"
    Debug.Print , "XP, 2003", "Default Find/Replace Behavior", Application.GetOption("Default Find/Replace Behavior") 'Default find/replace behavior
    Debug.Print , "XP, 2003", "Confirm Record Changes", Application.GetOption("Confirm Record Changes")               'Confirm, Record changes
    Debug.Print , "XP, 2003", "Confirm Document Deletions", Application.GetOption("Confirm Document Deletions")       'Confirm, Document deletions
    Debug.Print , "XP, 2003", "Confirm Action Queries", Application.GetOption("Confirm Action Queries")               'Confirm, Action queries
    Debug.Print , "XP, 2003", "Show Values in Indexed", Application.GetOption("Show Values in Indexed")               'Show list of values in, Local indexed fields
    Debug.Print , "XP, 2003", "Show Values in Non-Indexed", Application.GetOption("Show Values in Non-Indexed")       'Show list of values in, Local nonindexed fields
    Debug.Print , "XP, 2003", "Show Values in Remote", Application.GetOption("Show Values in Remote")                 'Show list of values in, ODBC fields
    Debug.Print , "XP, 2003", "Show Values in Snapshot", Application.GetOption("Show Values in Snapshot")             'Show list of values in, Records in local snapshot
    Debug.Print , "XP, 2003", "Show Values in Server", Application.GetOption("Show Values in Server")                 'Show list of values in, Records at server
    Debug.Print , "XP, 2003", "Show Values Limit", Application.GetOption("Show Values Limit")                         'Don't display lists where more than this number of records read
    Debug.Print ">>>Datasheet Tab"
    Debug.Print , "XP, 2003", "Default Font Color", Application.GetOption("Default Font Color")                       'Default colors, Font
    Debug.Print , "XP, 2003", "Default Background Color", Application.GetOption("Default Background Color")           'Default colors, Background
    Debug.Print , "XP, 2003", "Default Gridlines Color", Application.GetOption("Default Gridlines Color")             'Default colors, Gridlines
    Debug.Print , "XP, 2003", "Default Gridlines Horizontal", Application.GetOption("Default Gridlines Horizontal")   'Default gridlines showing, Horizontal
    Debug.Print , "XP, 2003", "Default Gridlines Vertical", Application.GetOption("Default Gridlines Vertical")       'Default gridlines showing, Vertical
    Debug.Print , "XP, 2003", "Default Column Width", Application.GetOption("Default Column Width")                   'Default column width
    Debug.Print , "XP, 2003", "Default Font Name", Application.GetOption("Default Font Name")                         'Default font, Font
    Debug.Print , "XP, 2003", "Default Font Weight", Application.GetOption("Default Font Weight")                     'Default font, Weight
    Debug.Print , "XP, 2003", "Default Font Size", Application.GetOption("Default Font Size")                         'Default font, Size
    Debug.Print , "XP, 2003", "Default Font Underline", Application.GetOption("Default Font Underline")               'Default font, Underline
    Debug.Print , "XP, 2003", "Default Font Italic", Application.GetOption("Default Font Italic")                     'Default font, Italic
    Debug.Print , "XP, 2003", "Default Cell Effect", Application.GetOption("Default Cell Effect")                     'Default cell effect
    Debug.Print , "XP, 2003", "Show Animations", Application.GetOption("Show Animations")                             'Show animations
    Debug.Print , "2003", "Show Smart Tags on Datasheets", Application.GetOption("Show Smart Tags on Datasheets")     'Show Smart Tags on Datasheets
    Debug.Print ">>>Keyboard Tab"
    Debug.Print , "XP, 2003", "Move After Enter", Application.GetOption("Move After Enter")                                   'Move after enter
    Debug.Print , "XP, 2003", "Behavior Entering Field", Application.GetOption("Behavior Entering Field")                     'Behavior entering field
    Debug.Print , "XP, 2003", "Arrow Key Behavior", Application.GetOption("Arrow Key Behavior")                               'Arrow key behavior
    Debug.Print , "XP, 2003", "Cursor Stops at First/Last Field", Application.GetOption("Cursor Stops at First/Last Field")   'Cursor stops at first/last field
    Debug.Print , "XP, 2003", "Ime Autocommit", Application.GetOption("Ime Autocommit")                                       'Auto commit
    Debug.Print , "XP, 2003", "Datasheet Ime Control", Application.GetOption("Datasheet Ime Control")                         'Datasheet IME control
    Debug.Print ">>>Tables/Queries Tab"
    Debug.Print , "XP, 2003", "Default Text Field Size", Application.GetOption("Default Text Field Size")                           'Table design, Default field sizes - Text
    Debug.Print , "XP, 2003", "Default Number Field Size", Application.GetOption("Default Number Field Size")                       'Table design, Default field sizes - Number
    Debug.Print , "XP, 2003", "Default Field Type", Application.GetOption("Default Field Type")                                     'Table design, Default field type
    Debug.Print , "XP, 2003", "AutoIndex on Import/Create", Application.GetOption("AutoIndex on Import/Create")                     'Table design, AutoIndex on Import/Create
    Debug.Print , "XP, 2003", "Show Table Names", Application.GetOption("Show Table Names")                                         'Query design, Show table names
    Debug.Print , "XP, 2003", "Output All Fields", Application.GetOption("Output All Fields")                                       'Query design, Output all fields
    Debug.Print , "XP, 2003", "Enable AutoJoin", Application.GetOption("Enable AutoJoin")                                           'Query design, Enable AutoJoin
    Debug.Print , "XP, 2003", "Run Permissions", Application.GetOption("Run Permissions")                                           'Query design, Run permissions
    Debug.Print , "XP, 2003", "ANSI Query Mode", Application.GetOption("ANSI Query Mode")                                           'Query design, SQL Server Compatible Syntax (ANSI 92) - This database
    Debug.Print , "XP, 2003", "ANSI Query Mode Default", Application.GetOption("ANSI Query Mode Default")                           'Query design, SQL Server Compatible Syntax (ANSI 92) - Default for new databases
    Debug.Print , "2003", "Query Design Font Name", Application.GetOption("Query Design Font Name")                                 'Query design, Query design font, Font
    Debug.Print , "2003", "Query Design Font Size", Application.GetOption("Query Design Font Size")                                 'Query design, Query design font, Size
    Debug.Print , "2003", "Show Property Update Options buttons", Application.GetOption("Show Property Update Options buttons")     'Show Property Update Options buttons
    Debug.Print ">>>Forms/Reports Tab"
    Debug.Print , "XP, 2003", "Selection Behavior", Application.GetOption("Selection Behavior")                       'Selection behavior
    Debug.Print , "XP, 2003", "Form Template", Application.GetOption("Form Template")                                 'Form template
    Debug.Print , "XP, 2003", "Report Template", Application.GetOption("Report Template")                             'Report template
    Debug.Print , "XP, 2003", "Always Use Event Procedures", Application.GetOption("Always Use Event Procedures")     'Always use event procedures
    Debug.Print , "2003", "Show Smart Tags on Forms", Application.GetOption("Show Smart Tags on Forms")               'Show Smart Tags on Forms
    Debug.Print , "2003", "Themed Form Controls", Application.GetOption("Themed Form Controls")                       'Show Windows Themed Controls on Forms
    Debug.Print ">>>Advanced Tab"
    Debug.Print , "XP, 2003", "Ignore DDE Requests", Application.GetOption("Ignore DDE Requests")                         'DDE operations, Ignore DDE requests
    Debug.Print , "XP, 2003", "Enable DDE Refresh", Application.GetOption("Enable DDE Refresh")                           'DDE operations, Enable DDE refresh
    Debug.Print , "XP, 2003", "Default File Format", Application.GetOption("Default File Format")                         'Default File Format
    Debug.Print , "XP", "Row Limit", Application.GetOption("Row Limit")                                             'Client-server settings, Default max records
    Debug.Print , "XP, 2003", "Default Open Mode for Databases", Application.GetOption("Default Open Mode for Databases") 'Default open mode
    Debug.Print , "XP, 2003", "Command-Line Arguments", Application.GetOption("Command-Line Arguments")                   'Command-line arguments
    Debug.Print , "XP, 2003", "OLE/DDE Timeout (sec)", Application.GetOption("OLE/DDE Timeout (sec)")                     'OLE/DDE timeout
    Debug.Print , "XP, 2003", "Default Record Locking", Application.GetOption("Default Record Locking")                   'Default record locking
    Debug.Print , "XP, 2003", "Refresh Interval (sec)", Application.GetOption("Refresh Interval (sec)")                   'Refresh interval
    Debug.Print , "XP, 2003", "Number of Update Retries", Application.GetOption("Number of Update Retries")               'Number of update retries
    Debug.Print , "XP, 2003", "ODBC Refresh Interval (sec)", Application.GetOption("ODBC Refresh Interval (sec)")         'ODBC fresh interval
    Debug.Print , "XP, 2003", "Update Retry Interval (msec)", Application.GetOption("Update Retry Interval (msec)")       'Update retry interval
    Debug.Print , "XP, 2003", "Use Row Level Locking", Application.GetOption("Use Row Level Locking")                     'Open databases using record-level locking
    Debug.Print , "XP", "Save Login and Password", Application.GetOption("Save Login and Password")                 'Save login and password
    Debug.Print ">>>Pages Tab"
    Debug.Print , "XP, 2003", "Section Indent", Application.GetOption("Section Indent")                                   'Default Designer Properties, Section Indent
    Debug.Print , "XP, 2003", "Alternate Row Color", Application.GetOption("Alternate Row Color")                         'Default Designer Properties, Alternative Row Color
    Debug.Print , "XP, 2003", "Caption Section Style", Application.GetOption("Caption Section Style")                     'Default Designer Properties, Caption Section Style
    Debug.Print , "XP, 2003", "Footer Section Style", Application.GetOption("Footer Section Style")                       'Default Designer Properties, Footer Section Style
    Debug.Print , "XP, 2003", "Use Default Page Folder", Application.GetOption("Use Default Page Folder")                 'Default Database/Project Properties, Use Default Page Folder
    Debug.Print , "XP, 2003", "Default Page Folder", Application.GetOption("Default Page Folder")                         'Default Database/Project Properties, Default Page Folder
    Debug.Print , "XP, 2003", "Use Default Connection File", Application.GetOption("Use Default Connection File")         'Default Database/Project Properties, Use Default Connection File
    Debug.Print , "XP, 2003", "Default Connection File", Application.GetOption("Default Connection File")                 'Default Database/Project Properties, Default Connection File
    Debug.Print ">>>Spelling Tab"
    Debug.Print , "XP, 2003", "Spelling dictionary language", Application.GetOption("Spelling dictionary language")                               'Dictionary Language
    Debug.Print , "XP, 2003", "Spelling add words to", Application.GetOption("Spelling add words to")                                             'Add words to
    Debug.Print , "XP, 2003", "Spelling suggest from main dictionary only", Application.GetOption("Spelling suggest from main dictionary only")   'Suggest from main dictionary only
    Debug.Print , "XP, 2003", "Spelling ignore words in UPPERCASE", Application.GetOption("Spelling ignore words in UPPERCASE")                   'Ignore words in UPPERCASE
    Debug.Print , "XP, 2003", "Spelling ignore words with number", Application.GetOption("Spelling ignore words with number")                     'Ignore words with numbers
    Debug.Print , "XP, 2003", "Spelling ignore Internet and file addresses", Application.GetOption("Spelling ignore Internet and file addresses") 'Ignore Internet and file addresses
    Debug.Print , "XP, 2003", "Spelling use German post-reform rules", Application.GetOption("Spelling use German post-reform rules")             'Language-specific, German: Use post-reform rules
    Debug.Print , "XP, 2003", "Spelling combine aux verb/adj", Application.GetOption("Spelling combine aux verb/adj")                             'Language-specific, Korean: Combine aux verb/adj.
    Debug.Print , "XP, 2003", "Spelling use auto-change list", Application.GetOption("Spelling use auto-change list")                             'Language-specific, Korean: Use auto-change list
    Debug.Print , "XP, 2003", "Spelling process compound nouns", Application.GetOption("Spelling process compound nouns")                         'Language-specific, Korean: Process compound nouns
    Debug.Print , "XP, 2003", "Spelling Hebrew modes", Application.GetOption("Spelling Hebrew modes")                                             'Language-specific, Hebrew modes
    Debug.Print , "XP, 2003", "Spelling Arabic modes", Application.GetOption("Spelling Arabic modes")                                             'Language-specific, Arabic modes
    Debug.Print ">>>International Tab"
    Debug.Print , "2003", "Default direction", Application.GetOption("Default direction")       'Right-to-Left, Default direction
    Debug.Print , "2003", "General alignment", Application.GetOption("General alignment")       'Right-to-Left, General alignment
    Debug.Print , "2003", "Cursor movement", Application.GetOption("Cursor movement")           'Right-to-Left, Cursor movement
    Debug.Print , "2003", "Use Hijri Calendar", Application.GetOption("Use Hijri Calendar")     'Use Hijri Calendar
    Debug.Print ">>>Error Checking Tab"
    Debug.Print , "2003", "Enable Error Checking", Application.GetOption("Enable Error Checking")                                                   'Settings, Enable error checking
    Debug.Print , "2003", "Error Checking Indicator Color", Application.GetOption("Error Checking Indicator Color")                                 'Settings, Error indicator color
    Debug.Print , "2003", "Unassociated Label and Control Error Checking", Application.GetOption("Unassociated Label and Control Error Checking")   'Form/Report Design Rules, Unassociated label and control
    Debug.Print , "2003", "Keyboard Shortcut Errors Error Checking", Application.GetOption("Keyboard Shortcut Errors Error Checking")               'Form/Report Design Rules, Keyboard shortcut errors
    Debug.Print , "2003", "Invalid Control Properties Error Checking", Application.GetOption("Invalid Control Properties Error Checking")           'Form/Report Design Rules, Invalid control properties
    Debug.Print , "2003", "Common Report Errors Error Checking", Application.GetOption("Common Report Errors Error Checking")                       'Form/Report Design Rules, Common report errors
    Debug.Print ">>>Popular Tab"
    Debug.Print "   >>>Creating databases section"
    Debug.Print , "2007", "Default File Format", Application.GetOption("Default File Format")
    Debug.Print , "2007", "Default Database Directory", Application.GetOption("Default Database Directory")
    Debug.Print , "2007", "New Database Sort Order", Application.GetOption("New Database Sort Order")
    Debug.Print ">>>Current Database Tab"
    Debug.Print "   >>>Application Options section"
    Debug.Print , "2007", "Auto Compact", Application.GetOption("Auto Compact")
    Debug.Print , "2007", "Remove Personal Information", Application.GetOption("Remove Personal Information")
    Debug.Print , "2007", "Themed Form Controls", Application.GetOption("Themed Form Controls")
    Debug.Print , "2007", "DesignWithData", Application.GetOption("DesignWithData")
    Debug.Print , "2007", "CheckTruncatedNumFields", Application.GetOption("CheckTruncatedNumFields")
    Debug.Print , "2007", "Picture Property Storage Format", Application.GetOption("Picture Property Storage Format")
    Debug.Print "   >>>Name AutoCorrect Options section"
    Debug.Print , "2007", "Track Name AutoCorrect Info", Application.GetOption("Track Name AutoCorrect Info")
    Debug.Print , "2007", "Perform Name AutoCorrect", Application.GetOption("Perform Name AutoCorrect")
    Debug.Print , "2007", "Log Name AutoCorrect Changes", Application.GetOption("Log Name AutoCorrect Changes")
    Debug.Print "   >>>Filter Lookup options for <Database Name> Database section"
Debug.Print , "2007",       'Show list of values in, Local indexed fields Show Values in Indexed
Debug.Print , "2007",       'Show list of values in, Local nonindexed fields Show Values in Non-Indexed
Debug.Print , "2007",       'Show list of values in, ODBC fields Show Values in Remote
Debug.Print , "2007",       'Show list of values in, Records in local snapshot Show Values in Snapshot
Debug.Print , "2007",       'Show list of values in, Records at server Show Values in Server
Debug.Print , "2007",       'Don't display lists where more than this number of records read Show Values Limit
    Debug.Print ">>>Datasheet Tab"
    Debug.Print "   >>>Default colors section"
Debug.Print , "2007",       'Font color Default Font Color
Debug.Print , "2007",       'Background color Default Background Color
Debug.Print , "2007",       'Alternate background color _64
Debug.Print , "2007",       'Gridlines color Default Gridlines Color
    Debug.Print "   >>>Gridlines and cell effects section"
Debug.Print , "2007",       'Default gridlines showing, Horizontal Default Gridlines Horizontal
Debug.Print , "2007",       'Default gridlines showing, Vertical Default Gridlines Vertical
Debug.Print , "2007",       'Default cell effect Default Cell Effect
Debug.Print , "2007",       'Default column width Default Column Width
    Debug.Print "   >>>Default font section"
Debug.Print , "2007",       'Font Default Font Name
Debug.Print , "2007",       'Size Default Font Size
Debug.Print , "2007",       'Weight Default Font Weight
Debug.Print , "2007",       'Underline Default Font Underline
Debug.Print , "2007",       'Italic Default Font Italic
    Debug.Print ">>>Object Designers Tab"
    Debug.Print "   >>>Table design section"
Debug.Print , "2007",       'Default text field size Default Text Field Size
Debug.Print , "2007",       'Default number field size Default Number Field Size
Debug.Print , "2007",       'Default field type Default Field Type
Debug.Print , "2007",       'AutoIndex on Import/Create AutoIndex on Import/Create
Debug.Print , "2007",       'Show Property Update Option Buttons Show Property Update Options Buttons
    Debug.Print "   >>>Query design section"
Debug.Print , "2007",       'Show table names Show Table Names
Debug.Print , "2007",       'Output all fields Output All Fields
Debug.Print , "2007",       'Enable AutoJoin Enable AutoJoin
Debug.Print , "2007",       'SQL Server Compatible Syntax (ANSI 92), This database ANSI Query Mode
Debug.Print , "2007",       'SQL Server Compatible Syntax (ANSI 92), Default for new databases ANSI Query Mode Default
Debug.Print , "2007",       'Query design font, Font Query Design Font Name
Debug.Print , "2007",       'Query design font, Size Query Design Font Size
    Debug.Print "   >>>Forms/Reports section"
Debug.Print , "2007",       'Selection behavior Selection Behavior
Debug.Print , "2007",       'Form template Form Template
Debug.Print , "2007",       'Report template Report Template
Debug.Print , "2007",       'Always use event procedures Always Use Event Procedures
    Debug.Print "   >>>Error checking section"
Debug.Print , "2007",       'Enable error checking Enable Error Checking
Debug.Print , "2007",       'Error indicator color Error Checking Indicator Color
Debug.Print , "2007",       'Check for unassociated label and control Unassociated Label and Control Error Checking
Debug.Print , "2007",       'Check for new unassociated labels New Unassociated Labels Error Checking
Debug.Print , "2007",       'Check for keyboard shortcut errors Keyboard Shortcut Errors Error Checking
Debug.Print , "2007",       'Check for invalid control properties Invalid Control Properties Error Checking
Debug.Print , "2007",       'Check for common report errors Common Report Errors Error Checking
    Debug.Print ">>>Proofing Tab"
    Debug.Print "   >>>When correcting spelling in Microsoft Office programs section"
Debug.Print , "2007",       'Ignore words in UPPERCASE Spelling ignore words in UPPERCASE
Debug.Print , "2007",       'Ignore words that contain numbers Spelling ignore words with number
Debug.Print , "2007",       'Ignore Internet and file addresses Spelling ignore Internet and file addresses
Debug.Print , "2007",       'Suggest from main dictionary only Spelling suggest from main dictionary only
Debug.Print , "2007",       'Dictionary Language Spelling dictionary language
    Debug.Print ">>>Advanced Tab"
    Debug.Print "   >>>Editing section"
Debug.Print , "2007",       'Move after enter Move After Enter
Debug.Print , "2007",       'Behavior entering field Behavior Entering Field
Debug.Print , "2007",       'Arrow key behavior Arrow Key Behavior
Debug.Print , "2007",       'Cursor stops at first/last field Cursor Stops at First/Last Field
Debug.Print , "2007",       'Default find/replace behavior Default Find/Replace Behavior
Debug.Print , "2007",       'Confirm, Record changes Confirm Record Changes
Debug.Print , "2007",       'Confirm, Document deletions Confirm Document Deletions
Debug.Print , "2007",       'Confirm, Action queries Confirm Action Queries
Debug.Print , "2007",       'Default direction Default Direction
Debug.Print , "2007",       'General alignment General Alignment
Debug.Print , "2007",       'Cursor movement Cursor Movement
Debug.Print , "2007",       'Datasheet IME control Datasheet Ime Control
Debug.Print , "2007",       'Use Hijri Calendar Use Hijri Calendar
    Debug.Print "   >>>Display section"
Debug.Print , "2007",       'Show this number of Recent Documents Size of MRU File List
Debug.Print , "2007",       'Status bar Show Status Bar
Debug.Print , "2007",       'Show animations Show Animations
Debug.Print , "2007",       'Show Smart Tags on Datasheets Show Smart Tags on Datasheets
Debug.Print , "2007",       'Show Smart Tags on Forms and Reports Show Smart Tags on Forms and Reports
Debug.Print , "2007",       'Show in Macro Design, Names column Show Macro Names Column
Debug.Print , "2007",       'Show in Macro Design, Conditions column Show Conditions Column
    Debug.Print "   >>>Printing section"
Debug.Print , "2007",       'Left margin Left Margin
Debug.Print , "2007",       'Right margin Right Margin
Debug.Print , "2007",       'Top margin Top Margin
Debug.Print , "2007",       'Bottom margin Bottom Margin
    Debug.Print "   >>>General section"
Debug.Print , "2007",       'Provide feedback with sound  Provide Feedback with Sound
Debug.Print , "2007",       'Use four-year digit year formatting, This database Four-Digit Year Formatting
Debug.Print , "2007",       'Use four-year digit year formatting, All databases Four-Digit Year Formatting All Databases
    Debug.Print "   >>>Advanced section"
Debug.Print , "2007",       'Open last used database when Access starts Open Last Used Database When Access Starts
Debug.Print , "2007",       'Default open mode Default Open Mode for Databases
Debug.Print , "2007",       'Default record locking Default Record Locking
Debug.Print , "2007",       'Open databases by using record-level locking Use Row Level Locking
Debug.Print , "2007",       'OLE/DDE timeout (sec) OLE/DDE Timeout (sec)
Debug.Print , "2007",       'Refresh interval (sec) Refresh Interval (sec)
Debug.Print , "2007",       'Number of update retries Number of Update Retries
Debug.Print , "2007",       'ODBC refresh interval (sec) ODBC Refresh Interval (sec)
Debug.Print , "2007",       'Update retry interval (msec) Update Retry Interval (msec)
Debug.Print , "2007",       'DDE operations, Ignore DDE requests Ignore DDE Requests
Debug.Print , "2007",       'DDE operations, Enable DDE refresh Enable DDE Refresh
Debug.Print , "2007",       'Command-line arguments Command-Line Arguments

    Set dbs = Nothing

End Sub