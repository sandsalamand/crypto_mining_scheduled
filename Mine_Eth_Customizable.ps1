Add-Type -AssemblyName System.Windows.Forms
[void][System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
$wsh = New-Object -ComObject WScript.Shell 
$open = 0

#------- Settings --------
$miner_exe_path = "C:\Users\sands\Desktop\gminer_2_44_windows64\miner.exe"
$miner_options = "--algo ethash --server us2.ethermine.org:4444 --user 0x95754B5F565325a15aD5Dae73FcD1C004232fdFB --templimit 70"
$open_time = 'PM'
$openMin = 73000
$openMax = 115900
$close_time = 'AM'
$closeMin = 91000
$closeMax = 115000
$manualMode = 0   #overrides the open range, starts miner.exe when this script is run. Use if you mine at weird times and don't want to adjust the open range

if($manualMode -eq 1)
{
    $Process = [Diagnostics.Process]::Start($miner_exe_path, $miner_options)   
    $id = $Process.Id
    $open = 1
    Write-Host "Process created with ID: $id at $hour"       
    Write-Host "sleeping for 4 seconds"            
    Start-Sleep -Seconds 4
}

while ($true) {
    $time = Get-Date -DisplayHint Time    
    $str = Out-String -InputObject $time -Width 8
    $tmp = $str -replace "[^0-9]" , ''
    $hour = [int]$tmp

    if(($str | Select-String -Pattern $open_time -SimpleMatch) -and ($open -eq 0) -and ($hour -gt $openMin) -and ($hour -lt $openMax))
    {
        try {            
            $Process = [Diagnostics.Process]::Start($miner_exe_path, $miner_options)   
            Write-Host "Process created with ID: $id at $hour"
	        $id = $Process.Id
	        $open = 1   
	        Write-Host "sleeping for 5 seconds"            
	        Start-Sleep -Seconds 5       
        } catch {            
            Write-Host "Failed to open process at $hour"            
        }
    }
    if(($str | Select-String -Pattern $close_time -SimpleMatch) -and ($open -eq 1) -and ($hour -gt $closeMin) -and ($hour -lt $closeMax))
    {
        try {            
            [Microsoft.VisualBasic.Interaction]::AppActivate($id)
            [System.Windows.Forms.SendKeys]::SendWait("Exit~")
            $Process.CloseMainWindow()
            Write-Host "Successfully killed the process with ID: $id at $hour"
	        $open = 0        
        } catch {            
            Write-Host "Failed to kill the process at $hour"            
        }
    }
    $wsh.SendKeys('+{F15}') #keeps the pc awake
    Start-Sleep -Seconds 240
}
pause