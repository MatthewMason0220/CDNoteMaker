#Include CDNoteMakerData.ahk
#Include CDNoteMakerLogic.ahk

; Creates an Instance of the GUI class and adds tabs
MyGui := Gui("+Resize", "CDNoteMaker")
Tab := MyGui.Add("Tab3",, ["Note", "CoC Verbiage", "Email Verbiage", "Files","CD Checklist", "LE Checklist"])


; Menu setup
MyMenuBar := MenuBar()
;MyMenuBar.Add("Load Note", LoadNote)
MyMenuBar.Add("Save Note", SaveNote)
MyMenuBar.Add("Clear Note", (*) => ClearNotes(MyGui))
; MyMenuBar.Add("Delete Current Note", DeleteNote)
MyGui.MenuBar := MyMenuBar

; Stuff in Group Box
Mygui.AddGroupBox("R3 w920")

; Column 1 - Group Box
summaryNameNum := MyGui.AddEdit("x35 y66 w140 ReadOnly",)
MyGui.AddText(,"Rate:")
MyGui.AddText("y+1","Fix/ARM:")

; Column 2 - Groupbox
MyGui.AddText("x95 y66 vLoanNumSum",)
summaryRate := MyGui.AddText('w80',"N/A")
summaryAmo := MyGui.AddText('y+1 w80',"N/A")

; Column 3 - Groupbox
MyGui.AddText("x190 y66","Term:")
MyGui.AddText("y+1","Cash Option:")
MyGui.AddText("y+1","Loan Type:")
summaryPointsLabel := MyGui.AddText("y+1 w70","Points:")

; Column 4 - Groupbox
summaryTerm := MyGui.AddText("x260 y66 w30","N/A")
summaryCashOption := MyGui.AddText('y+1 w50',"N/A")
summaryLoanType := MyGui.AddText('y+1 w50',"N/A")
summaryPoints := MyGui.AddText('y+1 w50',"N/A")

; Column 5 - Groupbox
MyGui.AddEdit("ReadOnly x315 y63 R4 w300", "State Info")

; Column 6 - Groupbox
MyGui.AddEdit("x+m R4 w300 vMiscNotes", "Misc Notes")


; Column 1 - Note Area
MyGui.AddText("x35 y136","Loan#:")
MyGui.Add("Text",,"Name:")
MyGui.Add("Text",,"State:")
MyGui.Add("Text",,"Rate:")
MyGui.Add("Text",,"Fixed or ARM:")
MyGui.Add("Text",,"Term")
MyGui.Add("Text",,"CashOption:")
MyGui.Add("Text",,"Loan Type:")
loanPointsOption := MyGui.Add("ComboBox",'vPointsOption Choose1 w70 y+10', PointOptions)
loanPointsOption.OnEvent('Change', (*) => AutoComplete(loanPointsOption, PointOptions) summaryPointsLabel.Text := loanPointsOption.Text . ':')
loanBpcLpc := MyGui.Add("ComboBox", "vLpcBpc w70 y+10 Choose1", BpcLpcOption)
loanBpcLpc.OnEvent('Change', (*) => AutoComplete(loanBpcLpc,BpcLpcOption))
MyGui.Add("Text",, "Borrower:") ;TODO: Add borrower options


; Column 2 - Note area
LoanNum := MyGui.AddEdit("x110 y132 vLoanNumber", )
LoanNum.OnEvent('Change', (*) => UpdateSummary(summaryNameNum, loanName, LoanNum))
loanName := MyGui.AddEdit("vLastName",)
loanName.OnEvent('Change', (*) => UpdateSummary(summaryNameNum, loanName, LoanNum))
loanUsState := MyGui.AddComboBox("vState",StateList)
loanUsState.OnEvent('Change', (*) => AutoComplete(loanUsState,StateList))
loanRate := MyGui.AddEdit("vRate",)
loanRate.OnEvent('Change',(*) => UpdateSummaryItem(summaryRate,loanRate))
loanAmortization := MyGui.AddComboBox("vAmortization",AmortizationTypes)
loanAmortization.OnEvent('Change',(*) => AutoComplete(loanAmortization,AmortizationTypes) UpdateSummaryCombo(summaryAmo,loanAmortization.Value,AmortizationTypes))
loanTerm := MyGui.AddEdit("vLoanTerm",)
loanTerm.OnEvent('LoseFocus',UpdateLoanTermSummary)
loanCashOption := MyGui.AddComboBox("vCashOption", CashOptions)
loanCashOption.OnEvent('Change',(*) => AutoComplete(loanCashOption,CashOptions) UpdateSummaryCombo(summaryCashOption,loancashoption.Value,CashOptions))
loanType := MyGui.AddComboBox("vLoanType ", LoanTypes)
loanType.OnEvent('Change', (*) => AutoComplete(loanType,LoanTypes) UpdateSummaryCombo(summaryLoanType,loanType.Value,LoanTypes))
loanPoints := MyGui.AddEdit("vPoints",)
loanPoints.OnEvent('Change', (*) => UpdateSummaryItem(summaryPoints,loanPoints))
MyGui.AddEdit("vLpcBpcAmt",)
MyGui.AddEdit("vBorrower",) 


; Column 3 - Note Area
MyGui.Add("Text", "x240 y136","Prop. Condition:")
MyGui.Add("Text",,"Loan Amount:")
MyGui.Add("Text",,"LTV:")
Mygui.Add("Text",,"LE Rate:")
lePointsOption := MyGui.Add("ComboBox",'vLePointsOption Choose1 w70 y+10', LePointOptions)
lePointsOption.OnEvent('Change', (*) => AutoComplete(lePointsOption, LePointOptions))
Mygui.Add("Text","y+9","Disclose Lock:")
Mygui.Add("Text",,"Current APR:")
Mygui.Add("Text",,"Disclosed APR:")
loanCashToClose := MyGui.Add("ComboBox","vCashToCloseType w70 y+10 Choose1",CashToCloseOptions)
loanCashToClose.OnEvent('Change', (*) => AutoComplete(loanCashToClose,CashToCloseOptions))
Mygui.Add("Text",,"Note Rate:")
Mygui.Add("Text",,"Undisc. Rate:")
Mygui.Add("Text",,"Excluded Points:")
Mygui.Add("Text",,"APOR:")

; Column 4 - Note Area
loanPropCondition := MyGui.AddComboBox("vPropCondition x340 y131",PropConditionList)
loanPropCondition.OnEvent('Change', (*) => AutoComplete(loanPropCondition,PropConditionList))
MyGui.AddEdit("vLoanAmount",)
MyGui.Add("Edit","vLoanLTV")
MyGui.AddEdit("vLeRate",)
MyGui.Add('Edit','vLePoints',)
loanLockType := MyGui.AddComboBox("vLockType", LockOptions)
loanLockType.OnEvent('Change', (*) => AutoComplete(loanLockType,LockOptions))
MyGui.AddEdit("vCurrentAPR",)
MyGui.AddEdit("vDisclosedAPR",)
MyGui.AddEdit("vCashToCloseAmt",)
noteRateField := MyGui.AddEdit("vNoteRate",)
noteRateField.OnEvent('LoseFocus', (*) => CalculateRateReduction(noteRateField.Value, undiscountRateField.Value, excludedPointsField.Value))
undiscountRateField := MyGui.AddEdit("vUndiscountedRate",)
undiscountRateField.OnEvent('LoseFocus', (*) => CalculateRateReduction(noteRateField.Value, undiscountRateField.Value, excludedPointsField.Value))
excludedPointsField := MyGui.AddEdit("vExcludedPoints",)
excludedPointsField.OnEvent('LoseFocus', (*) => CalculateRateReduction(noteRateField.Value, undiscountRateField.Value, excludedPointsField.Value))
Mygui.Add("Edit","vLoanAPOR",)

; Column 5 - Check boxes
MyGui.AddCheckbox("x470 y139 vDailyIntChange", "Daily Interest")
MyGui.AddCheckbox("vHoiChange", "HOI Change")
MyGui.AddCheckbox("vPropTaxChange", "Prop. Tax Change")
MyGui.AddCheckbox("vMipChange", "MIP Change")

MyGui.AddCheckbox("vDiscloseTerm", "Disclose Term")
MyGui.AddCheckbox("y+15 vNeedQM", "Need QM")
MyGui.AddCheckbox("vNeedSpouse","Need Spouse Info")
MyGui.AddCheckbox("vNeedFeeSheet", "Need Fee Sheet")
MyGui.AddCheckbox("vNeedTitle","Need Title Info")
MyGui.AddCheckbox("vHasUnallowableFees","Unallowable Fees")

MyGui.AddCheckbox("vRequestApproval y+15","Request Approval")

rateReductionField := MyGui.Add('Edit','vRateReduction y+60 ReadOnly',"Rate Reduction")

; Column 6 - CoC types
MyGui.Add('ComboBox','vTitleFeeChangeReason w200 x650 y130 Choose1', TitleFeeChangeReason)
feeType1 := MyGui.AddComboBox("vCocType1 w200 x585 y156 Choose32", CocTypes)
feeType1.OnEvent('Change', (*) => AutoComplete(feeType1,CocTypes))
feeType2 := MyGui.AddComboBox("vCocType2 w200 Choose9", CocTypes)
feeType2.OnEvent('Change',(*) =>  AutoComplete(feeType2,CocTypes))
feeType3 := MyGui.AddComboBox("vCocType3 w200 Choose39", CocTypes)
feeType3.OnEvent('Change',(*) =>  AutoComplete(feeType3,CocTypes))
feeType4 := MyGui.AddComboBox("vCocType4 w200 Choose24", CocTypes)
feeType4.OnEvent('Change',(*) =>  AutoComplete(feeType4,CocTypes))
feeType5 := MyGui.AddComboBox("vCocType5 w200 Choose27", CocTypes)
feeType5.OnEvent('Change',(*) =>  AutoComplete(feeType5,CocTypes))
feeType6 := MyGui.AddComboBox("vCocType6 w200 Choose29", CocTypes)
feeType6.OnEvent('Change',(*) =>  AutoComplete(feeType6,CocTypes))
feeType7 := MyGui.AddComboBox("vCocType7 w200 Choose12", CocTypes)
feeType7.OnEvent('Change',(*) =>  AutoComplete(feeType7,CocTypes))
feeType8 := MyGui.AddComboBox("vCocType8 w200 Choose10", CocTypes)
feeType8.OnEvent('Change',(*) =>  AutoComplete(feeType8,CocTypes))
feeType9 := MyGui.AddComboBox("vCocType9 w200 Choose49", CocTypes)
feeType9.OnEvent('Change',(*) =>  AutoComplete(feeType9,CocTypes))
feeType10 := MyGui.AddComboBox("vCocType10 w200 Choose20", CocTypes)
feeType10.OnEvent('Change',(*) =>  AutoComplete(feeType10,CocTypes))
feeType11 := MyGui.AddComboBox("vCocType11 w200 Choose28", CocTypes)
feeType11.OnEvent('Change',(*) =>  AutoComplete(feeType11,CocTypes))
feeType12 := MyGui.AddComboBox("vCocType12 w200 Choose47", CocTypes)
feeType12.OnEvent('Change',(*) =>  AutoComplete(feeType12,CocTypes))

; Column 7 - CoC Changes
feeChange1 := MyGui.AddComboBox("vCocChange1 x795 y156", FeeChanges)
feeChange1.OnEvent('Change', (*) => AutoComplete(feeChange1,FeeChanges))
feeChange2 := MyGui.AddComboBox("vCocChange2", FeeChanges)
feeChange2.OnEvent('Change', (*) => AutoComplete(feeChange2,FeeChanges))
feeChange3 := MyGui.AddComboBox("vCocChange3", FeeChanges)
feeChange3.OnEvent('Change', (*) => AutoComplete(feeChange3,FeeChanges))
feeChange4 := MyGui.AddComboBox("vCocChange4", FeeChanges)
feeChange4.OnEvent('Change', (*) => AutoComplete(feeChange4,FeeChanges))
feeChange5 := MyGui.AddComboBox("vCocChange5", FeeChanges)
feeChange5.OnEvent('Change', (*) => AutoComplete(feeChange5,FeeChanges))
feeChange6 := MyGui.AddComboBox("vCocChange6", FeeChanges)
feeChange6.OnEvent('Change', (*) => AutoComplete(feeChange6,FeeChanges))
feeChange7 := MyGui.AddComboBox("vCocChange7", FeeChanges)
feeChange7.OnEvent('Change', (*) => AutoComplete(feeChange7,FeeChanges))
feeChange8 := MyGui.AddComboBox("vCocChange8", FeeChanges)
feeChange8.OnEvent('Change', (*) => AutoComplete(feeChange8,FeeChanges))
feeChange9 := MyGui.AddComboBox("vCocChange9", FeeChanges)
feeChange9.OnEvent('Change', (*) => AutoComplete(feeChange9,FeeChanges))
feeChange10 := MyGui.AddComboBox("vCocChange10", FeeChanges)
feeChange10.OnEvent('Change', (*) => AutoComplete(feeChange10,FeeChanges))
feeChange11 := MyGui.AddComboBox("vCocChange11", FeeChanges)
feeChange11.OnEvent('Change', (*) => AutoComplete(feeChange11,FeeChanges))
feeChange12 := MyGui.AddComboBox("vCocChange12", FeeChanges)
feeChange12.OnEvent('Change', (*) => AutoComplete(feeChange12,FeeChanges))

; Tab 2 COC GUI
Tab.UseTab(2)
MyGui.AddText(, "CoC Verbiage")
CocVerbiage := MyGui.AddEdit("R30 w700 vCocVerbiage",)
GenerateCocButton := MyGui.AddButton("x+m", "Generate")
GenerateCocButton.OnEvent("Click",(*) => GenerateCoc(MyGui))

;Tab 3 Email GUI
Tab.UseTab(3)
MyGui.AddText(, "Email Verbiage")
emailVerbiage := MyGui.AddEdit("R30 w700 vEmailVerbiage",)
MyGui.AddText('x+m','Cure Amount:')
GenerateEmailButton := MyGui.AddButton(, "Generate")
GenerateEmailButton.OnEvent("Click",(*) => emailVerbiage.Value := GenerateEmail(MyGui))
cureEdit := MyGui.AddEdit('vCureAmount x805 y65 Number',)
cureEdit.OnEvent('LoseFocus', (*) => cureEdit.Value = Format(''))
/*TODO: Add Comboboxes for fails */

;Tab 4 File Manager
Tab.UseTab(4)
Mygui.Add("Text",,"To load a file Double click on it")
FileList := MyGui.Add("ListView","r20 w700", ["Name", "Last Updated"])
FileList.OnEvent("DoubleClick",SelectFile)
UpdateFileList()


;Tab 5 CD Checklist GUI
Tab.UseTab(5)
MyGui.AddText(, 'CD Checklist')
MyGui.AddCheckbox(,'Disclosure Tracking')
MyGui.AddCheckbox(,'Hit Buttons (on Loan Status)')
MyGui.AddCheckbox(,'Spouse')
MyGui.AddCheckbox(,'Closing Conditions')
MyGui.AddCheckbox(,'CD 5 - As Applicant')
MyGui.AddCheckbox(,'CD 1 - Dates and CoC')
MyGui.AddCheckbox(,'RegZ CD - Dates')
MyGui.AddCheckbox(,'2015 Discount Points')
MyGui.AddCheckbox(,'LE Loan amount and Term')
MyGui.AddCheckbox(,'Appraisal Reinspection Fee')
MyGui.AddCheckbox(,'State Specific Steps')
MyGui.AddCheckbox(,'State Disclosure')
MyGui.AddCheckbox(,'Run Compliance')

;Tab 6 LE Checklist GUI
Tab.UseTab(6)
MyGui.AddText(, 'LE Checklist')
MyGui.AddCheckbox(,'Disclosure Tracking')
MyGui.AddCheckbox(,'Hit Buttons (Redisclosure Request)')
MyGui.AddCheckbox(,'Update RegZ LE Date')
MyGui.AddCheckbox(,'Dicsount Points and Rate')
MyGui.AddCheckbox(,'Loan Amount and Term')
MyGui.AddCheckbox(,'Move CoC from CD1 to LE1')

MyGui.Show()

SaveNote(*){
    SaveNoteLogic(MyGui)
    UpdateFileList
}

LoadNote(*){
    noteName := "Jerry - 987987987"
    LoadNoteLogic(MyGui,noteName)
    UpdateAllSummaries()
    ; TODO: Figure out how to progamatically switch tab to main note page
}

DeleteNote(){
    MsgBox("Delete Note method")
}

SelectFile(FileList, RowNumber){
    rowText := FileList.GetText(RowNumber)
    FileListDoubleClick(MyGui, rowText)
    
}

UpdateAllSummaries(){
    UpdateSummary(summaryNameNum, loanName, LoanNum)
    UpdateSummaryItem(summaryRate,loanRate)
    UpdateSummaryItem(summaryTerm,loanTerm)
    UpdateSummaryItem(summaryPoints,loanPoints)
    UpdateSummaryCombo(summaryAmo,loanAmortization.Value,AmortizationTypes)
    UpdateSummaryCombo(summaryCashOption,loancashoption.Value,CashOptions)
    UpdateSummaryCombo(summaryLoanType,loanType.Value,LoanTypes)
    CalculateRateReduction(noteRateField.Value, undiscountRateField.Value, excludedPointsField.Value)
}

UpdateFileList(){
FileList.Delete()
loop files "C:\Users\Matt\Documents\AutoHotkey\XMLTester\*.*"
    FileList.Add(,A_LoopFileName, A_LoopFileTimeCreated)

FileList.ModifyCol() ;auto-size each column to fit its contents
}

UpdateLoanTermSummary(*){
    if (loanTerm.Value != ''){
        summaryTerm.Text := Number(loanTerm.Value) / 12
    }
}