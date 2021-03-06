﻿# @Author: Rolind Roy <rolindroy>
# @Date:   2017-11-13T12:41:21+05:30
# @Email:  hello@rolindroy.com
# @Filename: WSUSScript.ps1
# @Last modified by:   rolindroy
# @Last modified time: 2017-11-16T17:05:51+05:30
# Windows Updates Reporting Script.

# Including PDF Lib ------------------------------------------------------------
Unblock-File -Path ".\Lib\iTextSharp.dll"
Add-Type -Path ".\Lib\itextsharp.dll"

# PDF Functions ----------------------------------------------------------------
# Set basic PDF settings for the document
Function Create-PDF([iTextSharp.text.Document]$Document, [string]$File, [int32]$TopMargin, [int32]$BottomMargin, [int32]$LeftMargin, [int32]$RightMargin, [string]$Author = "RolindRoy")
{
    $Document.SetPageSize([iTextSharp.text.PageSize]::A4)
    $Document.SetMargins($LeftMargin, $RightMargin, $TopMargin, $BottomMargin)
    [void][iTextSharp.text.pdf.PdfWriter]::GetInstance($Document, [System.IO.File]::Create($File))
    $Document.AddAuthor($Author)
    $Document.AddCreator($Author)
    $Document.AddTitle("Created by $Author")
}
# Set header with Windows Logo
function PDF-Set-MainHeader([iTextSharp.text.Document]$Document, [string[]]$Dataset, [int32]$Cols = 3, [Switch]$Centered)
{

    # Header
    $absolutePath = (Get-Item -Path ".\" -Verbose).FullName
    $ImagePath = "$absolutePath\Lib\Assets\header.png"
    $tableHeadObj = New-Object iTextSharp.text.pdf.PDFPTable(2)
    #$t.SpacingBefore = 5
    $tableHeadObj.SpacingAfter = 10
    #if(!$Centered) { $t.HorizontalAlignment = 0 }
    $data = "Computer Detailed Status Report"

    # Text Settings
    $pHead = New-Object iTextSharp.text.Paragraph
    $pHead.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 11, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Gray')
    $pdfPhraseHead = New-Object iTextSharp.text.Phrase($data,$pHead.Font)
    $pdfCellHead = New-Object iTextSharp.text.pdf.PdfPCell($pdfPhraseHead)

    [iTextSharp.text.Image]$imgHead = [iTextSharp.text.Image]::GetInstance($ImagePath)
    $imgHead.ScalePercent(20)
    $imageCellHead =  New-Object iTextSharp.text.pdf.PdfPCell($imgHead)
    $imageCellHead.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $imageCellHead.PaddingLeft = 90

    # Border Settings
    $pdfCellHead.UseVariableBorders = 'true'
    $pdfCellHead.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)

    $tableHeadObj.AddCell($pdfCellHead);
    $tableHeadObj.AddCell($imageCellHead);
    $Document.Add($tableHeadObj)

}

# Create New section header with image
function PDF-Set-Section([iTextSharp.text.Document]$Document, [string]$Text, [string]$Image = "basic-info.png", [string]$flag = "false")
{
    $absolutePath = (Get-Item -Path ".\" -Verbose).FullName
    $imagePath = "$absolutePath\Lib\Assets\$Image"

    $tblBodyTop = New-Object iTextSharp.text.pdf.PDFPTable(2)
    $w = 1,18
    $tblBodyTop.SetWidths($w)

    [iTextSharp.text.Image]$imgBodyTop = [iTextSharp.text.Image]::GetInstance($imagePath)
    $imgBodyTop.ScalePercent(20)
    $imageCellBodyTop =  New-Object iTextSharp.text.pdf.PdfPCell($imgBodyTop)
    $imageCellBodyTop.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    if($flag -eq "false") { $imageCellBodyTop.PaddingTop = 0 } else {$imageCellBodyTop.PaddingTop = 31}

    $pBodyTop = New-Object iTextSharp.text.Paragraph
    $pBodyTop.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 9, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Gray')
    $pdfPhraseBodyTop = New-Object iTextSharp.text.Phrase($Text,$pBodyTop.Font)
    $pdfCellBodyTop = New-Object iTextSharp.text.pdf.PdfPCell($pdfPhraseBodyTop)
    $pdfCellBodyTop.UseVariableBorders = 'true'
    $pdfCellBodyTop.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $pdfCellBodyTop.BorderWidth = 1
    $pdfCellBodyTop.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
    if($flag -eq "false") { $pdfCellBodyTop.PaddingTop = 5 } else {$pdfCellBodyTop.PaddingTop = 35}


    $tblBodyTop.AddCell($imageCellBodyTop);
    $tblBodyTop.AddCell($pdfCellBodyTop);
    $Document.Add($tblBodyTop)
}

# Set body content with basic Info
function PDF-Set-BodyContent([iTextSharp.text.Document]$Document, [iTextSharp.text.pdf.PDFPTable]$tableObj, [string]$Key, [string]$Value)
{

    $emptyPhrase = New-Object iTextSharp.text.Phrase("")
    $emptyCell = New-Object iTextSharp.text.pdf.PdfPCell($emptyPhrase)
    $emptyCell.UseVariableBorders = 'true'
    $emptyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)

    $pKey = New-Object iTextSharp.text.Paragraph
    $pKey.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Black')

    $keyPhrase = New-Object iTextSharp.text.Phrase($Key,$pKey.Font)
    $keyCell = New-Object iTextSharp.text.pdf.PdfPCell($keyPhrase)
    $keyCell.UseVariableBorders = 'true'
    $keyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $keyCell.BorderWidth = 1
    $keyCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
    $keyCell.PaddingBottom = 8

    $pValue = New-Object iTextSharp.text.Paragraph
    $pValue.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Black')

    $valuePhrase = New-Object iTextSharp.text.Phrase($Value,$pValue.Font)
    $valueCell = New-Object iTextSharp.text.pdf.PdfPCell($valuePhrase)
    $valueCell.UseVariableBorders = 'true'
    $valueCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $valueCell.BorderWidth = 1
    $valueCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
    $valueCell.PaddingBottom = 8

    $tableObj.AddCell($emptyCell);
    $tableObj.AddCell($keyCell);
    $tableObj.AddCell($valueCell);

}

# Set Titles and Updates Information
function PDF-Set-BodyUpdateContent([iTextSharp.text.pdf.PDFPTable]$tableObj, [string]$Update, [string]$Classification, [string]$Approval, [string]$Status, [string]$flag = 'false')
{

    if ($flag -eq "true")
    {
        $dataset =@('Tit le','Classifications','Approval','Status')
        $emptyPhrase = New-Object iTextSharp.text.Phrase("")
        $emptyCell = New-Object iTextSharp.text.pdf.PdfPCell($emptyPhrase)
        $emptyCell.UseVariableBorders = 'true'
        $emptyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
        $tableObj.AddCell($emptyCell);
        foreach($data in $Dataset)
        {
            $pBodyTop = New-Object iTextSharp.text.Paragraph
            $pBodyTop.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 8, [iTextSharp.text.Font]::BOLD, [iTextSharp.text.BaseColor]::'Gray')
            $pdfPhraseBodyTop = New-Object iTextSharp.text.Phrase($data,$pBodyTop.Font)
            $pdfCellBodyTop = New-Object iTextSharp.text.pdf.PdfPCell($pdfPhraseBodyTop)
            $pdfCellBodyTop.UseVariableBorders = 'true'
            $pdfCellBodyTop.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
            $pdfCellBodyTop.BorderWidth = 1
            $pdfCellBodyTop.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
            $pdfCellBodyTop.PaddingBottom = 8
            $tableObj.AddCell($pdfCellBodyTop);
        }
    }
    else
    {
        $emptyPhrase = New-Object iTextSharp.text.Phrase("")
        $emptyCell = New-Object iTextSharp.text.pdf.PdfPCell($emptyPhrase)
        $emptyCell.UseVariableBorders = 'true'
        $emptyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)

        $pUpdate = New-Object iTextSharp.text.Paragraph
        $pUpdate.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 7, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Blue')

        $UpdatePhrase = New-Object iTextSharp.text.Phrase($Update,$pUpdate.Font)
        $updateCell = New-Object iTextSharp.text.pdf.PdfPCell($UpdatePhrase)
        $updateCell.UseVariableBorders = 'true'
        $updateCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
        $updateCell.BorderWidth = 1
        $updateCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
        $updateCell.PaddingBottom = 7

        $pClassifications = New-Object iTextSharp.text.Paragraph
        $pClassifications.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 7, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Black')

        $classificationPhrase = New-Object iTextSharp.text.Phrase($Classification,$pClassifications.Font)
        $classificationCell = New-Object iTextSharp.text.pdf.PdfPCell($classificationPhrase)
        $classificationCell.UseVariableBorders = 'true'
        $classificationCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
        $classificationCell.BorderWidth = 1
        $classificationCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
        $classificationCell.PaddingBottom = 7

        $pApproval = New-Object iTextSharp.text.Paragraph
        $pApproval.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 7, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Blue')

        $approvalPhrase = New-Object iTextSharp.text.Phrase($Approval,$pApproval.Font)
        $approvalCell = New-Object iTextSharp.text.pdf.PdfPCell($approvalPhrase)
        $approvalCell.UseVariableBorders = 'true'
        $approvalCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
        $approvalCell.BorderWidth = 1
        $approvalCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
        $approvalCell.PaddingBottom = 7

        $pStatus = New-Object iTextSharp.text.Paragraph
        $pStatus.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 7, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Blue')

        $statusPhrase = New-Object iTextSharp.text.Phrase($Status,$pStatus.Font)
        $statusCell = New-Object iTextSharp.text.pdf.PdfPCell($statusPhrase)
        $statusCell.UseVariableBorders = 'true'
        $statusCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
        $statusCell.BorderWidth = 1
        $statusCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
        $statusCell.PaddingBottom = 7

        $tableObj.AddCell($emptyCell);
        $tableObj.AddCell($updateCell);
        $tableObj.AddCell($classificationCell);
        $tableObj.AddCell($approvalCell);
        $tableObj.AddCell($statusCell);
    }
}

# Set Footer Content
function PDF-Set-FooterContent([iTextSharp.text.Document]$Document, [iTextSharp.text.pdf.PDFPTable]$tableObj, [string]$Key, [string]$Value)
{

    $emptyPhrase = New-Object iTextSharp.text.Phrase("")
    $emptyCell = New-Object iTextSharp.text.pdf.PdfPCell($emptyPhrase)
    $emptyCell.UseVariableBorders = 'true'
    $emptyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)

    $pKey = New-Object iTextSharp.text.Paragraph
    $pKey.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Gray')

    $keyPhrase = New-Object iTextSharp.text.Phrase($Key,$pKey.Font)
    $keyCell = New-Object iTextSharp.text.pdf.PdfPCell($keyPhrase)
    $keyCell.UseVariableBorders = 'true'
    $keyCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $keyCell.BorderWidth = 1
    $keyCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
    $keyCell.PaddingBottom = 8

    $pValue = New-Object iTextSharp.text.Paragraph
    $pValue.Font = [iTextSharp.text.FontFactory]::GetFont('Calibri', 8, [iTextSharp.text.Font]::NORMAL, [iTextSharp.text.BaseColor]::'Gray')

    $valuePhrase = New-Object iTextSharp.text.Phrase($Value,$pValue.Font)
    $valueCell = New-Object iTextSharp.text.pdf.PdfPCell($valuePhrase)
    $valueCell.UseVariableBorders = 'true'
    $valueCell.BorderColor = New-Object iTextSharp.text.BaseColor(255,255,255)
    $valueCell.BorderWidth = 1
    $valueCell.BorderColorBottom = New-Object iTextSharp.text.BaseColor(192,192,192)
    $valueCell.PaddingBottom = 8

    $tableObj.AddCell($emptyCell);
    $tableObj.AddCell($keyCell);
    $tableObj.AddCell($valueCell);

}

# File Name and Supporting Directory Func.  ------------------------------------
# Get New filename
function GET-FileName([string]$Name = "MultipleHost")
{
    $date = Get-Date -format M_d_yyyy
    $absolutePath = (Get-Item -Path ".\" -Verbose).FullName
    if (!(Test-Path "$OutputDir\$Name-$date")) {
        New-Item -ItemType directory -Path "$OutputDir\$Name-$date" | Out-Null
    }

    $OutputDir = "$absolutePath\Output\$Name-$date"
    $Name = $Name.ToUpper()
    $OutputFilePath = "$OutputDir\Updates Report for $Name"

    if (!(Test-Path "$OutputFilePath.pdf"))
    {
      return $OutputFilePath
    }
    else
    {
        $FLAG = 1
        $i = 0
        while ($FLAG)
        {
            $i ++
            if (!(Test-Path "$OutputFilePath-$i.pdf"))
            {
                $filename = "$OutputFilePath-$i"
                $FLAG = 0
            }

        }
        return $filename
    }
}

$date = Get-Date -format M_d_yyyy
$absolutePath = (Get-Item -Path ".\" -Verbose).FullName

# check Conf directory
$ConfigDir = "$absolutePath\Conf"
if (!(Test-Path $ConfigDir)) {
  New-Item -ItemType directory -Path $ConfigDir | Out-Null
}

# Check ConfigFile
$ConfigPath = "$ConfigDir\ConfigFile.txt"
if (!(Test-Path $ConfigPath)) {
  New-Item -ItemType file -Path $ConfigPath | Out-Null
}

# Check Output Directory
$OutputDir = "$absolutePath\Output"
if (!(Test-Path $OutputDir)) {
  New-Item -ItemType directory -Path $OutputDir | Out-Null
}


# WSUS Service -----------------------------------------------------------------

#$MyDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
#Set-Location $MyDir
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
#$WSUSTargetHostName = 'SGPVSNAVMT001'
$date = Get-Date -format M_d_yyyy

# Create WSUS Service Object
$wsusFlag = "false"
$Failedcount = 0
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
do
{
    $WSUSTargetHostName = read-host -prompt "`n`nEnter the WSUS Target Host Name:"
    Try
    {
        
        $wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($WSUSTargetHostName,$False,8530) #Change to SCCM server name
        $wsusFlag = "true"
    }
    Catch
    {   
        if( $Failedcount -ge 5)
        {
            Write-Host "No of failed attempts : $Failedcount" -foregroundcolor "Red"
            Write-Host "Program will terminate in 5 seconds" -foregroundcolor "Red"
            Start-Sleep -s 5
            exit
        }
        else
        {
            Write-Host "Invalid hostname, Try again." -foregroundcolor "Red"
            $Failedcount++
        }
    }
} 
until($wsusFlag -eq "true")
#Clear-Host
$computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope

#Exclude the following states from update list
$updatescope.ExcludedInstallationStates = 'NotApplicable','Unknown','Installed'

#Create Forward and Reverse lookup
$groups = @{}
$dataHolder = @()
$wsus.GetComputerTargetGroups() | ForEach {$groups[$_.Name]=$_.id;$groups[$_.ID]=$_.name}

Do {
  $keepRunning = $true
    
    Write-Host "`n`t`tWSUS Patch Report Script - Menu" -Fore Magenta
    Write-Host "`t--------------------------------------------------------------`n" 
    #Write-Host "`t`tPlease select the option you require`n" -Fore Cyan
    Write-Host "`t[1] List All WSUS Computer Groups" -Fore Cyan
    Write-Host "`t[2] Pull Updates for a Specific Computer Group" -Fore Cyan
    Write-Host "`t[3] Pull Updates for Multiple hosts **" -Fore Cyan
    Write-Host "`t[4] Quit`n" -Fore Cyan
    Write-Host "`t** Note: Please specify the hostnames in .\Conf\ConfigFile.txt`n" -Fore DarkYellow
    Write-Host "`t--------------------------------------------------------------" 
    Write-Output "`t`t`t`t`t - Rolind Roy <hello@rolindroy.com>`n`n"

    $choice1 = read-host -prompt "Select number & press enter:"
    
  Switch ($choice1) {
    # ======================== Choice 1 ========================================
    "1" {

          Write-Host "`n`nComputer Target Groups: `n"
          $wsus.GetComputerTargetGroups() | foreach { Write-Host "`t" $_.Name -ForegroundColor "Green" }
    }
    # ======================== Choice 2 ========================================
  	"2" {
          $DataHolder = @()
          $computerscope4 = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
          $updatescope4 = New-Object Microsoft.UpdateServices.Administration.UpdateScope
          # Only list updates that are needed
          $updatescope4.ExcludedInstallationStates = 'NotApplicable','Unknown','Installed'
          $classificatios = $wsus.GetUpdateClassifications() | ?{$_.Title -eq "Critical Updates" -OR $_.Title -eq "Security Updates"}
          $updateScope.Classifications.Clear()
          $updateScope.Classifications.AddRange($classificatios)
          # Only list updates that are approved
          #$updatescope4.A pprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved;

          $TargetGroup = Read-Host -prompt "Please enter a group name:"
          $OutputFileName = GET-FileName -Name $TargetGroup
          if (!($groups[$TargetGroup]))
          {
                Write-Host "ERROR :: No Compute group $TargetGroup Found!" -foregroundcolor "Red"
                $keepRunning = $True
                Break
          }
          $pcgroup = @($wsus.GetComputerTargets($computerscope4) | Where {$_.ComputerTargetGroupIds -eq $groups[$TargetGroup]}) | Select -expand Id

          # PDF Write ---------------------------------------------------------
          $pdf = New-Object iTextSharp.text.Document
          Create-PDF -Document $pdf -File "$OutputFileName.pdf" -TopMargin 40 -BottomMargin 4 -LeftMargin 0 -RightMargin 0
          $pdf.Open()
          PDF-Set-MainHeader -Document $pdf

          $pcinfo = $wsus.GetSummariesPerComputerTarget($updatescope4,$computerscope4) | Where {$pcgroup -Contains $_.ComputerTargetID} | ForEach {
            	$computerscope2 = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
            	$computerscope2.NameIncludes = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).FullDomainName

                $outClient = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).FullDomainName
                $outIp = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).IPAddress
                $outOS = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).OSDescription
                $outUpdate = ($_.NotInstalledCount + $_.DownloadedCount)
                $outLastSync = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).LastReportedStatusTime

                # Write Header -------------------------------------------------
                PDF-Set-Section -Document $pdf -Text $outClient -Image "basic-info.png"

                $tblBodyMid = New-Object iTextSharp.text.pdf.PDFPTable(3)
                $w = 1,5,13
                $tblBodyMid.SetWidths($w)

                PDF-Set-BodyContent -Document $pdf -tableObj $tblBodyMid -Key "Operating System" -Value $outOS
                PDF-Set-BodyContent -Document $pdf -tableObj $tblBodyMid -Key "Service Pack" -Value "None"
                PDF-Set-BodyContent -Document $pdf -tableObj $tblBodyMid -Key "IP Address" -Value $outIp
                PDF-Set-BodyContent -Document $pdf -tableObj $tblBodyMid -Key "Last Status Reported" -Value $outLastSync
                PDF-Set-BodyContent -Document $pdf -tableObj $tblBodyMid -Key "Language" -Value "en-US"

                $pdf.Add($tblBodyMid)
                #$pdf.NewPage()

                # Write Updates ------------------------------------------------

                PDF-Set-Section -Document $pdf -Text "Update Detailed Status Report" -Image "updates.png" -flag "true"

                $tblBodyContent = New-Object iTextSharp.text.pdf.PDFPTable(5)
                $width = 1,6,4,4,4
                $tblBodyContent.SetWidths($width)
                PDF-Set-BodyUpdateContent -tableObj $tblBodyContent -Update "" -Classification "" -Approval "" -Status "" -flag "true"

                $wsus.GetSummariesPerUpdate($updatescope4,$computerscope2) | foreach {
                   $output_update = $wsus.GetUpdate($_.UpdateId).Title
                   $output_classification = $wsus.GetUpdate($_.UpdateId).UpdateClassificationTitle
                   $output_approved = if($wsus.GetUpdate($_.UpdateId).IsApproved) { "Approved"} else { "Not Approved" }

                   PDF-Set-BodyUpdateContent -tableObj $tblBodyContent -Update $output_update -Classification $output_classification -Approval $output_approved -Status "Not Installed"
                }
                $pdf.Add($tblBodyContent)
                $pdf.NewPage()

          }

          PDF-Set-Section -Document $pdf -Text "Report Options" -Image "reports.png"
          # Write Footer -------------------------------------------------------
          $tblBodyFooter = New-Object iTextSharp.text.pdf.PDFPTable(3)
          $fw = 1,5,13
          $tblBodyFooter.SetWidths($fw)
          $dt = Get-Date -format 'M/d/yyyy HH:mm'
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Report Type:" -Value "Detailed Report"
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Classifications:" -Value "Critical Updates, Security Updates"
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Computer Groups:" -Value $TargetGroup.ToUpper()
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Status:" -Value "Needed, Failed"
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Downstream Servers:" -Value "All replica downstream servers"
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Report Data Collected:" -Value $dt
          PDF-Set-FooterContent -Document $pdf -tableObj $tblBodyFooter -Key "Server used for reporting data:" -Value $WSUSTargetHostName.ToUpper()
          $pdf.Add($tblBodyFooter)
          $pdf.Close()
       
          Write-Host "`n`nProcess Completed !"
          Write-Host "Output file: $OutputFileName.pdf`n" -foregroundcolor Green
    }

    # ======================== Choice 3 ========================================
    "3" {
      If ((Get-Content $ConfigPath) -eq $Null) {
            Write-Host "ERROR :: .\Conf\ConfigFile.txt is empty. !" -foregroundcolor "Red"
            $keepRunning = $True
            Break
      }
      $OutputFileName = GET-FileName -Name "Multiple hosts"
      $pdfAll = New-Object iTextSharp.text.Document
      Create-PDF -Document $pdfAll -File "$OutputFileName.pdf" -TopMargin 40 -BottomMargin 4 -LeftMargin 0 -RightMargin 0
      $pdfAll.Open()
      PDF-Set-MainHeader -Document $pdfAll
      Get-Content $ConfigPath | ForEach-Object {
          $TargetHost = $_
          $DataHolder_op3 = @()
          $computerscope_opt3 = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
          $updatescope_opt3 = New-Object Microsoft.UpdateServices.Administration.UpdateScope

          # Only list updates that are needed
          $updatescope_opt3.ExcludedInstallationStates = 'NotApplicable','Unknown','Installed'
          $classificatios = $wsus.GetUpdateClassifications() | ?{$_.Title -eq "Critical Updates" -OR $_.Title -eq "Security Updates"}
          $updatescope_opt3.Classifications.Clear()
          $updatescope_opt3.Classifications.AddRange($classificatios)
          # Only list updates that are approved
          #$updatescope_opt3.ApprovedStates = [Microsoft.UpdateServices.Administration.ApprovedStates]::LatestRevisionApproved;

          $pcgroup = @($wsus.GetComputerTargets($computerscope_opt3) | Where {$_.FullDomainName -eq $TargetHost}) | Select -expand Id

          $pcinfo = $wsus.GetSummariesPerComputerTarget($updatescope_opt3,$computerscope_opt3) | Where {$pcgroup -Contains $_.ComputerTargetID} | ForEach {
            	$computerscope2 = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
            	$computerscope2.NameIncludes = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).FullDomainName

                $outClient = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).FullDomainName
                $outIp = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).IPAddress
                $outOS = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).OSDescription
                $outUpdate = ($_.NotInstalledCount + $_.DownloadedCount)
                $outLastSync = $wsus.GetComputerTarget(([guid]$_.ComputerTargetId)).LastReportedStatusTime

                PDF-Set-Section -Document $pdfAll -Text $outClient -Image "basic-info.png"
                # Write Header -------------------------------------------------
                $tblBodyMid = New-Object iTextSharp.text.pdf.PDFPTable(3)
                $w = 1,5,13
                $tblBodyMid.SetWidths($w)

                PDF-Set-BodyContent -Document $pdfAll -tableObj $tblBodyMid -Key "Operating System" -Value $outOS
                PDF-Set-BodyContent -Document $pdfAll -tableObj $tblBodyMid -Key "Service Pack" -Value "None"
                PDF-Set-BodyContent -Document $pdfAll -tableObj $tblBodyMid -Key "IP Address" -Value $outIp
                PDF-Set-BodyContent -Document $pdfAll -tableObj $tblBodyMid -Key "Last Status Reported" -Value $outLastSync
                PDF-Set-BodyContent -Document $pdfAll -tableObj $tblBodyMid -Key "Language" -Value "en-US"

                $pdfAll.Add($tblBodyMid)

                # Write Updates ------------------------------------------------
                PDF-Set-Section -Document $pdfAll -Text "Update Detailed Status Report" -Image "updates.png" -flag "true"

                $tblBodyContent = New-Object iTextSharp.text.pdf.PDFPTable(5)
                $width = 1,6,4,4,4
                $tblBodyContent.SetWidths($width)
                PDF-Set-BodyUpdateContent -tableObj $tblBodyContent -Update "" -Classification "" -Approval "" -Status "" -flag "true"

                $wsus.GetSummariesPerUpdate($updatescope_opt3,$computerscope2) | foreach {
                   $output_update = $wsus.GetUpdate($_.UpdateId).Title
                   $output_classification = $wsus.GetUpdate($_.UpdateId).UpdateClassificationTitle
                   $output_approved = if($wsus.GetUpdate($_.UpdateId).IsApproved) { "Approved"} else { "Not Approved" }

                   PDF-Set-BodyUpdateContent -tableObj $tblBodyContent -Update $output_update -Classification $output_classification -Approval $output_approved -Status "Not Installed"
                }
                $pdfAll.Add($tblBodyContent)
                $pdfAll.NewPage()

                # --------------------------------------------------------------
          }
           $pdfAll.NewPage()
      }
      PDF-Set-Section -Document $pdfAll -Text "Report Options" -Image "reports.png"
      # Write Footer -----------------------------------------------------------
      $tblBodyFooter = New-Object iTextSharp.text.pdf.PDFPTable(3)
      $fw = 1,5,13
      $tblBodyFooter.SetWidths($fw)
      $dt = Get-Date -format 'M/d/yyyy HH:mm'
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Report Type:" -Value "Detailed Report"
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Classifications:" -Value "Critical Updates, Security Updates"
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Computer Groups:" -Value "All Computers".ToUpper()
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Status:" -Value "Needed, Failed"
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Downstream Servers:" -Value "All replica downstream servers"
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Report Data Collected:" -Value $dt
      PDF-Set-FooterContent -Document $pdfAll -tableObj $tblBodyFooter -Key "Server used for reporting data:" -Value $WSUSTargetHostName.ToUpper()
      $pdfAll.Add($tblBodyFooter)
      # ------------------------------------------------------------------------
      $pdfAll.Close()
      Write-Host "`n`nProcess Completed !"
      Write-Host "Output file: $OutputFileName.pdf`n" -foregroundcolor Green
    }
    # ======================== Choice 4 ========================================
    "4" {
      $keepRunning = $False
      Write-Host "Program will terminate in 5 seconds" -foregroundcolor "Red"
      Start-Sleep -s 5
      exit
    }
  }
} while ($keepRunning -eq $true)
