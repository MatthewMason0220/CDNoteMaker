#Requires AutoHotkey v2.0
#Include XMLTool.ahk
#Include CDNoteMakerGUI.ahk
#Include CDNoteMakerData.ahk

SavePath := "C:\Users\Matt\Documents\AutoHotkey\XMLTester\"

; Creates the base text for the email using data from the provided CD Note GUI
GenerateEmail(Mygui){
    noteInfo := Mygui.Submit(false)
    emailText := ['Good Day,']
    
    if (noteInfo.CureAmount != ''){
        if (Number(noteInfo.CureAmount) > 0){
            emailText.Push('We are seeing a total increase in CUREFEE for the amount of $' . noteInfo.CureAmount . '. Is there a valid reason for this increase? If not, the difference will need to be cured.')
        }
    }

    if (noteInfo.HasUnallowableFees){
        emailText.Push('Please note that we are getting an unallowable fees fail that you will need to get with your Account Manager with to fix prior to the loan closing. This will not hold up the ICD from being released. `r`n(Unallowables breakdown Snippet)')
    }

   if(noteInfo.CashToCloseAmt != ''){
        switch noteInfo.CashToCloseType{        
            Case 'To': 
                if (noteInfo.CashOption == 'No_Cash-Out Refi'){
                    emailText.Push('Please note that we are currently showing cash TO the borrower in the amount of $' . noteInfo.CashToCloseAmt . ' on this No cash-out refinance.')
                }
            
            Case 'From': 
                if (noteInfo.CashOption == 'Cash-Out Refi'){
                    emailText.Push('Please note that we are currently showing cash FROM the borrower in the amount of $' . noteInfo.CashToCloseAmt . ' on this cash-out refinance.')
                }
        }
    }

    /*
    TODO: add fields to Email page for fails (probably 3 fails)

    if (noteInfo.FailAmt > 0){

    }
*/

    if (noteInfo.NeedQM){
        emailText.Push("I have checked our system and I don't see a QM form uploaded for the current lock. Please provide a QM form for the current lock at a rate of " . noteInfo.Rate . '%')
    }

    if (noteInfo.NeedSpouse){
        emailText.Push("According to EC the borrower is marked as married, Please confirm and provide the spouse's name as" .  SubStr(noteInfo.State, 5) . " is a spousal state and this needs to be on the CD.")
    }

    if (noteInfo.NeedFeeSheet)
        emailText.Push("Please provide a title fee sheet for the desired loan amount. `r`nCurrent loan amount is " noteInfo.LoanAmount "`r`nLTV: " noteInfo.LoanLTV "%")

    if (noteInfo.NeedTitle){
        emailText.Push("Please provide the following information for the title company. `r`n`tTitle Company's name: `r`n`tAddress: `r`n`tTitle Reference Number: `r`n`tCompany State License ID: `r`n`tMain Contact's Name: `r`n`tMain Contact's State License ID: `r`n`tEmail: `r`n`tPhone Number:")
    }

    /*
    if (noteInfo.NoteRate != '' and noteInfo.UndiscountedRate != '')
    */

    if (noteInfo.RequestApproval){
        emailText.Push("Currently we have BORROWERSNAME on the Closing Disclosure, Please confirm the name of the spouse to be listed on the CD (if applicable) `r`n`r`nLoan Amount: " . noteInfo.LoanAmount . "`r`nLTV: " noteInfo.LoanLTV "%`r`nCash " . noteInfo.CashToCloseType . " the Borrower: $" .  noteinfo.CashToCloseAmt . "`r`n(snippet COC page 3) `r`nPlease see attached and advise if we are good to send an initial CD. `r`n`r`nThank you!")
        ;TODO: add variable for LTV
    }

    count := 1
    output := ''
        for text in emailText{
        if (count = emailText.Length){
            output .= text
        }
        else {
            output .= text . '`r`n `r`n'
            count++
        }
    }

    return output 
}

; Creates the base text for the Change of Concerns(CoC) using data from the provided CD Note GUI
GenerateCoc(Mygui){
    noteInfo := Mygui.Submit(false)
    cocText := Array()

    switch noteInfo.LockType{
        case "New Lock":
            cocText.Push("Pricing is changing from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts, to the locked rate of " noteInfo.Rate "% and " noteinfo.Points " discounts, per the borrower's request.")
        case "LC Lock":
            cocText.Push("Pricing is changing from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts with $xx in lender credits, to the locked rate of " noteInfo.Rate "% and " noteinfo.Points " discounts with $xx in lender credits, per the borrower's request.")
        case "Update Pricing":
            cocText.Push("Pricing is changing from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts, to the updated pricing of " noteInfo.Rate "% and " noteinfo.Points " discounts, per the borrower's request. ")
        case "Lock":
            cocText.Push("The loan was locked at " noteInfo.Rate "% and " noteinfo.Points " discounts, per the borrower's request.")
        case "Relock Request":
            cocText.Push("The loan was locked at " noteInfo.LeRate "% and " noteInfo.LePoints " discounts and was relocked at " noteInfo.Rate "% and " noteinfo.Points " discounts, per the borrower's request.")
        case "Relock Reason":
            cocText.Push("The loan was locked at " noteInfo.LeRate "% and " noteInfo.LePoints " discounts and was relocked at " noteInfo.Rate "% and " noteinfo.Points " discounts, due to (put reason here for when discounts are increasing: pricing hit for what reason?)")
        case "Expired Relock":
            cocText.Push("Because the previous lock expired pricing has changed from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts and was relocked at " noteInfo.Rate "% and " noteinfo.Points " discounts, per the borrower's request.")
        case "Extension":
            cocText.Push("The loan was extended at the same rate of " noteInfo.Rate "% at a .X% cost for a new price of " noteInfo.Points " discount / lender credit per the borrower's request.")
        case "Free Extension":
            cocText.Push("The loan was extended at the same rate of " noteInfo.Rate "% at no extra cost per the borrower's request.")
        case "LPC to BPC":
            cocText.Push("Lock is changing from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts with lender paid compensation, to the locked rate of  " noteInfo.Rate "% and " noteinfo.Points " discounts with borrower paid compensation, per the borrower's request. ")
        case "BPC to LPC":
            cocText.Push("Lock is changing from " noteInfo.LeRate "% and " noteInfo.LePoints " discounts  with borrower paid compensation, to the locked rate of  " noteInfo.Rate "% and " noteinfo.Points " discounts with lender paid compensation, per the borrower's request. ")
    }

    if (noteInfo.CurrentAPR != '' and noteInfo.DisclosedAPR != ''){
        if (Abs(Number(noteInfo.CurrentAPR) - Number(noteInfo.DisclosedAPR)) > .125){
            ;cocText.Push("This caused a change in APR greater than .125%.")
            cocText[cocText.Length] .= " This caused a change in APR greater than .125%."
        }
    }

    if (noteInfo.PropCondition = 'Subj. to Change'){
        cocText.Push('Due to the appraisal coming back "subject to repairs" a $200 reinspection fee has been added.')
    }

    ;TODO: Add Disclose Loan AMT combobox (put that in label column)

    if (noteInfo.DiscloseTerm and noteInfo.LoanTerm != ''){
        ;TODO: Remove decimal places
        cocText.Push("Change in loan term from X to" . (Number(noteInfo.LoanTerm)/12) . " yrs per the borrower's request.")
    }

    if (noteinfo.Borrower != ''){
        ;TODO: add toggle for borrower type
        cocText.Push(noteInfo.Borrower . " was added to the disclosure as a Title only individual per the borrower's request.")
    }

    ; TODO: Add flood cert logic and gui element

    if (noteInfo.DailyIntChange)
        cocText.Push("Closing date and date for disbursement of funds have been updated.")
    
    if (noteInfo.HoiChange)
        cocText.Push("Homeowners insurance has been updated due to receiving updated insurance documents.")
    
    if (noteInfo.PropTaxChange)
        cocText.Push("Property taxes have been updated due to receiving updated tax documents.")
    
    if (noteInfo.MipChange)
        cocText.Push("Updated the Monthly Mortgage Insurance to match updated FHA guidelines.")
    
    ;TODO: add a switch to update titlefeestext to whatever verbiage is appropriate for these title fees
    
    titleFeesText := []
    switch noteInfo.TitleFeeChangeReason{
        default: titleFeesText.Push("The following title fees have been updated due to receiving an updated fee sheet from title: ")
        case "New Title Company": titleFeesText.Push("The following fees have increased or have been added due switching from XX to XX because the borrower shopped for their own title company: ")
    }
    
    if (noteInfo.CocChange1 != '') 
        titleFeesText.Push(noteInfo.CocType1 . ' ' . noteInfo.CocChange1)
    if (noteInfo.CocChange2 != '') 
        titleFeesText.Push(noteInfo.CocType2 . ' ' . noteInfo.CocChange2)
    if (noteInfo.CocChange3 != '') 
        titleFeesText.Push(noteInfo.CocType3 . ' ' . noteInfo.CocChange3)    
    if (noteInfo.CocChange4 != '') 
        titleFeesText.Push(noteInfo.CocType4 . ' ' . noteInfo.CocChange4)  
    if (noteInfo.CocChange5 != '') 
        titleFeesText.Push(noteInfo.CocType5 . ' ' . noteInfo.CocChange5)  
    if (noteInfo.CocChange6 != '') 
        titleFeesText.Push(noteInfo.CocType6 . ' ' . noteInfo.CocChange6)  
    if (noteInfo.CocChange7 != '') 
        titleFeesText.Push(noteInfo.CocType7 . ' ' . noteInfo.CocChange7)  
    if (noteInfo.CocChange8 != '') 
        titleFeesText.Push(noteInfo.CocType8 . ' ' . noteInfo.CocChange8)  
    if (noteInfo.CocChange9 != '') 
        titleFeesText.Push(noteInfo.CocType9 . ' ' . noteInfo.CocChange9)  
    if (noteInfo.CocChange10 != '') 
        titleFeesText.Push(noteInfo.CocType10 . ' ' . noteInfo.CocChange10)  
    if (noteInfo.CocChange11 != '') 
        titleFeesText.Push(noteInfo.CocType11 . ' ' . noteInfo.CocChange11)  

    count := 1
    output := ''
    if (titleFeesText.Length > 1){
        for text in titleFeesText{
            if (text != ''){
                if (count = titleFeesText.Length or count = 1){
                    output .= text                    
                    count++
                    
                }
                else{
                    output .= " " . text . ", "
                    count++
                }
            }
        }
    }
    cocText.Push(output)
    

    count := 1
    output := ''
        for text in cocText{
        if (count = cocText.Length){
            output .= text
            count++
        }
        else {
            output .= text . '`r`n'
            count++
        }
    }

    CocVerbiage.Value := output
}

; Combines the provided coc type and the coc change in to a single string
CocItemAdder(cocType, cocChange){    
        return cocType . ' ' . cocChange    
}

; Calculates rate reduction with handling for cases outside of expectation.
CalculateRateReduction(noteRate, undiscountRate, ExcludedPoints){
    if (noteRate != '' and undiscountRate != '' and ExcludedPoints != ''){
        output := 0
        output := (Number(undiscountRate) - Number(noteRate)) / ExcludedPoints
        if (output < .150)
            rateReductionField.Value := 'Failed'
        else
            rateReductionField.Value := output
    }
    else {
        rateReductionField.Value := 'Rate Reduction'
    }
}

UpdateSummary(summaryNameNum, LoanName, LoanNum){
    summaryNameNum.Value := LoanName.Value . ' - ' LoanNum.Value
    ;TODO: figure out why it's using index instead of text
    summaryPoints.Text := loanPoints.Text
}

UpdateSummaryItem(summaryItem,loanItem){
    summaryItem.Value := loanItem.Value
}

UpdateSummaryCombo(summaryItem,itemIndex,itemList){
    ;TODO put a check in to avoid errors

    
    if (itemIndex = 0)
        summaryItem.text := ""
    else    
        summaryItem.Value := itemList[itemIndex]
}

;TODO - Method to make edits auto format for money
FormatCash(number){

}

SaveNoteLogic(gui){
    noteInfo := gui.Submit(false)
; TODO: update it to save by iterating over the controls rather than this non-dynamic approach.

    if (noteInfo.LoanNumber != ''){
        xmlFile := XML()        
        
        xmlFile.addElement("root","LoanNumber",noteInfo.LoanNumber)
        xmlFile.addElement("root","LastName",noteInfo.LastName)
        xmlFile.addElement("root","State",noteInfo.State)
        xmlFile.addElement("root","Rate",noteInfo.Rate)
        xmlFile.addElement("root","Amortization",noteInfo.Amortization)
        xmlFile.addElement("root","LoanTerm",noteInfo.LoanTerm)       
        xmlFile.addElement("root","CashOption",noteInfo.CashOption)
        xmlFile.addElement("root","LoanType",noteInfo.LoanType)
        xmlFile.addElement("root","PointsOption",noteInfo.PointsOption)
        xmlFile.addElement("root","Points",noteInfo.Points)
        xmlFile.addElement("root","LpcBpc",noteInfo.LpcBpc)
        xmlFile.addElement("root","LpcBpcAmt",noteInfo.LpcBpcAmt)
        xmlFile.addElement("root","Borrower",noteInfo.Borrower)
        xmlFile.addElement("root","PropCondition",noteInfo.PropCondition)
        xmlFile.addElement("root","LoanAmount",noteInfo.LoanAmount)
        xmlFile.addElement("root","LoanLTV",noteInfo.LoanLTV)
        xmlFile.addElement("root","LeRate",noteInfo.LeRate)
        xmlFile.addElement("root","LePointsOption",noteInfo.LePointsOption)
        xmlFile.addElement("root","LePoints",noteInfo.LePoints)
        xmlFile.addElement("root","LockType",noteInfo.LockType)
        xmlFile.addElement("root","CurrentAPR",noteInfo.CurrentAPR)
        xmlFile.addElement("root","DisclosedAPR",noteInfo.DisclosedAPR)
        xmlFile.addElement("root","CashToCloseType",noteInfo.CashToCloseType)
        xmlFile.addElement("root","CashToCloseAmt",noteInfo.CashToCloseAmt)
        xmlFile.addElement("root","NoteRate",noteInfo.NoteRate)
        xmlFile.addElement("root","UndiscountedRate",noteInfo.UndiscountedRate)
        xmlFile.addElement("root","ExcludedPoints",noteInfo.ExcludedPoints)
        xmlFile.addElement("root","LoanAPOR",noteInfo.LoanAPOR)
        xmlFile.addElement("root","DailyIntChange",noteInfo.DailyIntChange)
        xmlFile.addElement("root","HoiChange",noteInfo.HoiChange)
        xmlFile.addElement("root","PropTaxChange",noteInfo.PropTaxChange)
        xmlFile.addElement("root","MipChange",noteInfo.MipChange)
        xmlFile.addElement("root","DiscloseTerm",noteInfo.DiscloseTerm)
        xmlFile.addElement("root","NeedQM",noteInfo.NeedQM)
        xmlFile.addElement("root","NeedSpouse",noteInfo.NeedSpouse)
        xmlFile.addElement("root","NeedFeeSheet",noteInfo.NeedFeeSheet)
        xmlFile.addElement("root","NeedTitle",noteInfo.NeedTitle)
        xmlFile.addElement("root","HasUnallowableFees",noteInfo.HasUnallowableFees)
        xmlFile.addElement("root","RequestApproval",noteInfo.RequestApproval)
        xmlFile.addElement("root","TitleFeeChangeReason",noteInfo.TitleFeeChangeReason)
        xmlFile.addElement("root","CocType1",noteInfo.CocType1)
        xmlFile.addElement("root","CocChange1",noteInfo.CocChange1)
        xmlFile.addElement("root","CocType2",noteInfo.CocType2)
        xmlFile.addElement("root","CocChange2",noteInfo.CocChange2)
        xmlFile.addElement("root","CocType3",noteInfo.CocType3)
        xmlFile.addElement("root","CocChange3",noteInfo.CocChange3)
        xmlFile.addElement("root","CocType4",noteInfo.CocType4)
        xmlFile.addElement("root","CocChange4",noteInfo.CocChange4)
        xmlFile.addElement("root","CocType5",noteInfo.CocType5)
        xmlFile.addElement("root","CocChange5",noteInfo.CocChange5)
        xmlFile.addElement("root","CocType6",noteInfo.CocType6)
        xmlFile.addElement("root","CocChange6",noteInfo.CocChange6)
        xmlFile.addElement("root","CocType7",noteInfo.CocType7)
        xmlFile.addElement("root","CocChange7",noteInfo.CocChange7)
        xmlFile.addElement("root","CocType8",noteInfo.CocType8)
        xmlFile.addElement("root","CocChange8",noteInfo.CocChange8)
        xmlFile.addElement("root","CocType9",noteInfo.CocType9)
        xmlFile.addElement("root","CocChange9",noteInfo.CocChange9)
        xmlFile.addElement("root","CocType10",noteInfo.CocType10)
        xmlFile.addElement("root","CocChange10",noteInfo.CocChange10)
        xmlFile.addElement("root","CocType11",noteInfo.CocType11)
        xmlFile.addElement("root","CocChange11",noteInfo.CocChange11)
        xmlFile.addElement("root","CocType12",noteInfo.CocType12)
        xmlFile.addElement("root","CocChange12",noteInfo.CocChange12)      
        xmlFile.addElement("root","MiscNotes",noteInfo.MiscNotes)
        xmlFile.addElement("root","CocVerbiage",noteInfo.CocVerbiage)
        xmlFile.addElement("root","EmailVerbiage",noteInfo.EmailVerbiage)
        xmlFile.addElement("root","CureAmount",noteInfo.CureAmount)
        
        fileName := noteInfo.LastName " - " noteInfo.LoanNumber
        if (FileExist(Savepath filename) or FileExist(Savepath noteInfo.LoanNumber)){
            if (noteInfo.LastName = '')
                FileDelete(SavePath noteinfo.LoanNumber)
            else
                FileDelete(SavePath fileName)
        }

        if !(DirExist(SavePath))
            DirCreate(SavePath)

        if (noteInfo.LastName != '')
            xmlFile.saveXML(SavePath fileName)
        else
            xmlFile.saveXML(SavePath noteInfo.LoanNumber)

        MsgBox("Note has been saved.")
    }
}


LoadNoteLogic(gui, noteName){        
    xmlFile := XML(noteName)

    for control in gui{        
        if (control.Name != ''){            
            try {
                if (control.Type = "ComboBox")
                    control.Text := xmlFile.getElement(control.Name)
                else
                    control.Value := xmlFile.getElement(control.Name)                
            } catch Error as e {
                MsgBox(e.Message)
            }
        }        
    }        
}

FileListDoubleClick(gui,fileName){
    result := MsgBox("Would you like to load " fileName "?",,"YesNo")
    if (result = "yes"){
        LoadNoteLogic(gui, SavePath fileName)
        UpdateAllSummaries()
    }    
}

/*
 * Iterates over every control and sets any that are named and matching the below types to the default value 
 */
ClearNotes(gui){
    for control in gui{
        if (control.Name != ''){
            if (ArrayHasItem(FieldsThatHaveDefaults,control.name)){
                control.value := ArrayGetItem(FieldsAndDefaults,control.Name)                
            }
            else{
                switch control.Type{
                    case "Edit": control.value := ''
                    case "ComboBox": control.value := 0
                    case "CheckBox": control.value := 0                  
                }
            }
        }
    }
    UpdateAllSummaries()
}

/**
 * True if the array has an instance of the provided item (only test with string arrays)
 */
ArrayHasItem(arr,item){
    output := false
    for a in arr{
        if (a = item){
            output := true
            break
        }
    }
    return output
}

/**
 * returns an object from the array with a matching name (custom made for specific array. Don't use elsewhere for now)  
 */
ArrayGetItem(arr,name){
    for a in arr{        
        if (a[1] = name)    
            return a[2]
    }
}

/*
URL to where i got this script from.
https://www.reddit.com/r/AutoHotkey/comments/10wufmn/help_with_ahk_v2_gui_with_combobox_adding/

Specifically this was Ark565's code modified by skyracer85 on reddit.
*/
AutoComplete(ComboBox, entriesList) {
    ; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
    currContent := ComboBox.Text
    if ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
        return

    valueFound := false
    for index, value in entriesList
    {
        ; Check if the current value matches the target value
        if (value = currContent)
        {
            valueFound := true
            break ; Exit the loop if the value is found
        }
    }
    if (valueFound)
        return ; Exit Nested request

    Start :=0, End :=0
    MakeShort(0, &Start, &End)
    try {
        if (ControlChooseString(ComboBox.Text, ComboBox) > 0) {
            Start := StrLen(currContent)
            End := StrLen(ComboBox.Text)
            PostMessage 0x0142, 0, MakeLong(Start, End), , "ahk_id" ComboBox.Hwnd
        }
    } Catch as e {
        ControlSetText currContent, ComboBox
        PostMessage 0x0142, 0, MakeLong(StrLen(currContent), StrLen(currContent)), , "ahk_id " ComboBox.Hwnd
    }

    MakeShort(Long, &LoWord, &HiWord) {
        LoWord := Long & 0xffff
        , HiWord := Long >> 16
    }

    MakeLong(LoWord, HiWord) {
        return (HiWord << 16) | (LoWord & 0xffff)
    }
}