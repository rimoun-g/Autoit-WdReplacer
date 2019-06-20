#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <File.au3>
#include <Word.au3>
#include <Excel.au3>
#Include <WinAPIEx.au3>
MsgBox (48, "Warning", "please save and close your word files to avoid any issues")

#Region ### START Koda GUI section ### Form=
$frmMainForm = GUICreate("Replace text in word files", 1100, 600)
$btnSelect = GUICtrlCreateButton("Select", 530, 8, 150, 25)
$lstFiles = GUICtrlCreateListview("", 8, 50, 700, 530, BitOR($WS_HSCROLL,$WS_VSCROLL))
_GUICtrlListView_InsertColumn($lstFiles, 0, "Files", 680)
GUICtrlSetLimit ( $lstFiles, 10000000)
$FileListCon = GUICtrlCreateContextMenu ( $lstFiles )

$FolderPath = GUICtrlCreateInput("", 88, 10, 420, 20)
$Pathlbl = GUICtrlCreateLabel("Folder Path", 10, 15)
$countItemslbl = GUICtrlCreateLabel("0 File(s)", 720, 550,100)
$gettingItemslbl = GUICtrlCreateLabel("......", 720, 570,100)
$idCheckbox = GUICtrlCreateCheckbox("Include files in Subfolders", 700, 10, 185, 25)

$txtOldText = GUICtrlCreateInput("Old Text", 715, 50, 175, 20)
$txtNewText = GUICtrlCreateInput("New Text", 900, 50, 175, 20)

$btnReplaceWords = GUICtrlCreateButton("Do (0) Replacements per file", 900, 550, 190, 35)
$btnAddWords = GUICtrlCreateButton("Add text Manually", 920, 80, 150, 25)
$btnAddWordsXl = GUICtrlCreateButton("Add text from Excel", 720, 80, 150, 25)
$lstWords = GUICtrlCreateListview("", 720, 110, 370, 430, BitOR($WS_HSCROLL,$WS_VSCROLL))
$lstWordsCon = GUICtrlCreateContextMenu ( $lstWords )
$Deles = GUICtrlCreateMenuItem("Delete", $lstWordsCon)
_GUICtrlListView_InsertColumn($lstWords, 0, "(((Replace)))", 182,2)
_GUICtrlListView_InsertColumn($lstWords, 0, "(((Find)))", 182,2)
GUICtrlSetLimit ( $lstWords, 10000000)

$OpenFile = GUICtrlCreateMenuItem("Open File", $FileListCon)
;~ $OpenFolder = GUICtrlCreateMenuItem("Open Folder", $FileListCon)
$Del = GUICtrlCreateMenuItem("Delete", $FileListCon)
$ClearFileList = GUICtrlCreateMenuItem("Delete All Items", $FileListCon)
$ClearWordList = GUICtrlCreateMenuItem("Delete All Items", $lstWordsCon)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnSelect
			MsgBox(48,"Warning","Please test the replacement on one file before doing replacements on a big scale.")
			$G = FileSelectFolder ("Choose word folder", @ScriptDir)
			 GUICtrlSetData($FolderPath,$G)
			 GetFilesList($G,"*.docx", _IsChecked($idCheckbox))
		Case $Del
			_GUICtrlListView_DeleteItemsSelected ($lstFiles)
			GUICtrlSetData($countItemslbl, _GUICtrlListView_GetItemCount ( $lstFiles )& " File(s)")
		Case $btnReplaceWords
		   ReplaceWords()
		Case $btnAddWords
			AddWords(Guictrlread($txtOldText),Guictrlread($txtNewText))
			GUICtrlSetData($btnReplaceWords, "Do (" & _GUICtrlListView_GetItemCount ( $lstWords )& ") replacemnts per file")
		Case $Deles
			_GUICtrlListView_DeleteItemsSelected  ($lstWords)
			GUICtrlSetData($btnReplaceWords,"Do (" & _GUICtrlListView_GetItemCount ( $lstWords )&") replacemnts per file")
		Case $btnAddWordsXl
			MsgBox(48,"Warning","The excel sheet should have the old text in Column A and the new in Column B starting from cell A2 as follows ."&@CRLF&@CRLF& "	old Text	|	New text "&@CRLF& "	old word	|	New word")
			$N = FileOpenDialog("Choose Excel File",@ScriptDir,"Excel files (*.xlsx)")
			if $N <> "" Then AddTextFromExcel($N)
			GUICtrlSetData($btnReplaceWords, "Do (" & _GUICtrlListView_GetItemCount ( $lstWords )& ") replacemnts per file")
		Case $OpenFile
			openfilefromList($lstFiles, 0)
;~ 		Case $OpenFolder
;~ 			openfolder($lstFiles,2)
		Case $ClearFileList
			DeletListViewItems($lstFiles)
			GUICtrlSetData($countItemslbl, "0 File(s)")
		Case $ClearWordList
			DeletListViewItems($lstWords)
			GUICtrlSetData($btnReplaceWords, "Do (" & _GUICtrlListView_GetItemCount ( $lstWords )& ") replacemnts per file")

	EndSwitch
WEnd


;~ ======================================== Get the files list based on word files extension *.docx ===========================================
Func GetFilesList ($Path = @ScriptDir, $Type = "*", $recurs = $FLTAR_NORECUR)
Local $recur_val
Local $FPath = $Path

	if $Type = "" Then $Type = "*" ; the type is specified in in the user interface, however it can be amended to accept other extensions like .doc - .docm
	if $recurs = True Then
		$recur_val = $FLTAR_RECUR
	Else
		$recur_val  = $FLTAR_NORECUR
	EndIf
	if $FPath <> "" Then
			GUICtrlSetData($gettingItemslbl,"Getting files....")
			GUICtrlSetState($btnSelect, 128)
			Local $FileList = _FileListToArrayRec ($FPath,$Type,1,$recur_val,Default,$FLTAR_FULLPATH)

		if UBound ($FileList) > 1 Then
			if @error Then MsgBox (0,"","Error code: " & @error & " - Extended code: " & @extended)

			DeletListViewItems($lstFiles)
			For $i = 1 To $FileList[0]
				GUICtrlCreateListViewItem($FileList[$i],$lstFiles)
			Next
			GUICtrlSetData($gettingItemslbl,"Done Getting files")
			GUICtrlSetData($countItemslbl, UBound ($FileList) -1& " File(s)")

		Else
			GUICtrlSetData($gettingItemslbl,"No files found")
			MsgBox (16,"Error","Cannot find any files")

		EndIf
		GUICtrlSetState($btnSelect, 64)
	EndIf
EndFunc;==================End of the GetFilesList function ============>



;~ ======================== Check if the checkbox is checked or not and return true if it is checked ===========================================
Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc ;=================== End of _IsChecked ==============>



;~ ======================================== the replace function loobs through the list of replacements for each word file in the files list to perform all repalcements ===============
Func ReplaceWords()
Local $countItems = _GUICtrlListView_GetItemCount($lstFiles)
Local $File
if  $countItems > 0 Then
		GUICtrlSetState($btnReplaceWords, 128)
		$oWord = _Word_Create(False) ;opening word application
		If @error Then  MsgBox(16+48, "Error","Error Creating document object." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
	For $i = 0 To $countItems - 1
		$File = _GUICtrlListView_GetItemText($lstFiles,$i) ; opening word file from list of files
		$oDoc = _Word_DocOpen($oWord, $File, Default,Default, False)
		If @error Then  MsgBox(16+48, "Error","Error opening the document." & @CRLF & "@error = " & @error & ", @extended = " & @extended)
			For $j = 0 To _GUICtrlListView_GetItemCount ( $lstWords ) -1 ;loobs through the list of replacements to perform all of them in each document
				$oRangeFound = _Word_DocFindReplace($oDoc,  _GUICtrlListView_GetItemText($lstWords,$j), _GUICtrlListView_GetItemText($lstWords,$j,1))
			Next
		_Word_DocClose ($oDoc, $WdSaveChanges) ;closed the word document
		GUICtrlSetData($gettingItemslbl,"Replacing..." & Int((($i+1)/($countItems))*100) & "%")
	Next

	_Word_Quit($oWord) ; closes the word application
	GUICtrlSetData($gettingItemslbl,"Done Replacing")
	GUICtrlSetState($btnReplaceWords, 64)
Else
	msgbox(16,"Error", "No files to be replaced")
EndIf
EndFunc ;==== End of ReplaceWords function ================>




;~ =========================================== add words from the text boxes to the list in order to add replacemnts ===========================================
Func AddWords( $txtOldText, $txtNewText)
 GUICtrlCreateListViewItem($txtOldText&"|"&$txtNewText,$lstWords)
EndFunc ;============ End of AddWords function



;~ ============================ get list of replacements from excel file and add them to repalcements list instead of enterin them one by one =======================
Func AddTextFromExcel($ExcelFile)
	 $oExcel = ObjCreate("Excel.Application") ; creates xl application
	  $oWorkbook = _Excel_BookOpen($oExcel,$ExcelFile,False,False) ; opens the xl file
Local Const $xlUp = -4162
With $oWorkbook.ActiveSheet ; process active sheet
	$oRangeLast = .UsedRange.SpecialCells($xlCellTypeLastCell) ; get a Range that contains the last used cells
	$iRowCount = .Range(.Cells(1, 1), .Cells($oRangeLast.Row, $oRangeLast.Column)).Rows.Count ; get the the row count for the range starting in row/column 1 and ending at the last used row/column
	$iLastCell = .Cells($iRowCount + 1, "A").End($xlUp).Row ; start in the row following the last used row and move up to the first used cell in column "B" and grab this row number
	Global $text = _Excel_RangeRead($oWorkbook, Default, "A2:B" & $iLastCell) ; gets the used range and store it as an array
	_Excel_Close($oWorkbook,Default,Default) ; close the xl file

	For $i = 0 To UBound($text) - 1 ; loop through the range array to populate the list with values
	AddWords($text[$i][0],$text[$i][1])
	Next

EndWith

EndFunc ;===================== End of AddTextFromExcel function =========================>


;~ =========================================== open the selected file in the files list ===========================================
 Func openfilefromList($ListID, $ListType = 1)
	If $ListType = 1 Then
        $Y = _GUICtrlListBox_GetCount ( $ListID )
	   if $Y < 1 Then
		  MsgBox(0,"Error","List is Empty")
	   Else
		$W =   _GUICtrlListBox_GetText($ListID, _GUICtrlListBox_GetCurSel($ListID))
		 ShellExecute($W)
	   EndIf
	Else
		$Y = _GUICtrlListView_GetItemCount ( $ListID )
		 if $Y < 1 Then
		  MsgBox(0,"Error","List is Empty")
		 Else
		  $W = _GUICtrlListView_GetSelectedIndices ($ListID, True)
		  for $i = 0 To UBound ($W)
		$fl = _GUICtrlListView_GetItemText ($ListID, $i)
		ShellExecute($fl)
		Next
		 EndIf
	EndIf
 EndFunc  ;===================== End of openfilefromList function =========================>



;~ =========================================== open the folder of the selected file in the files list ===========================================
 Func openfolder($ListID, $listType = 1 ) ; not used
	If $ListType = 1 Then
	   $Y = _GUICtrlListBox_GetCount ( $ListID )
	   if $Y < 1 Then
			MsgBox(0,"Error","List is Empty")
	   Else
			$W =  _GUICtrlListBox_GetText($ListID, _GUICtrlListBox_GetCurSel($ListID))
			_WinAPI_ShellOpenFolderAndSelectItems($W)
	   EndIf
	Else
			$Y = _GUICtrlListView_GetItemCount ( $ListID )
		 if $Y < 1 Then
		  MsgBox(0,"Error","List is Empty")
		 Else
		  $W = _GUICtrlListView_GetSelectedIndices ($ListID, True)
		  for $i = 0 To UBound ($W)
			$fl = _GUICtrlListView_GetItemText ($ListID, $i)
			_WinAPI_ShellOpenFolderAndSelectItems($fl)
		  Next
		 EndIf
	EndIf
 EndFunc ;===================== End of openfolder function =========================>



;~ =========================================== oDelete item in the files list ===========================================
Func DeletListViewItems($listID)
	_GUICtrlListView_DeleteAllItems($listID)
	EndFunc ;===================== End of DeletListViewItems function =========================>
