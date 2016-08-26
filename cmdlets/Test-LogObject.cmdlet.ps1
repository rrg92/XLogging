Function Test-LogObject {
	[CmdLetBinding()]
	param($Path = $null 
			,[switch]$Screen = $false
			,[switch]$Buffer = $false
			,$LogLevel = 3
			,$LoggingNumber = 15
			,$BufferIsHostDelay = 1
			,[switch]$BufferIsHost = $false
			, $RandomColoring=$null
			,$RetainedInterval = 1
			,$RetainedCount = 5
			,$IdentString = "`t"
	)
	
	try {

		$o = New-LogObject
		$o.LogTo = @()
		$o.BufferIsHost = $BufferIsHost;
		$o.IgnoreLogFail = $false;
		$o.IdentString = $IdentString;
		
		if($Screen) {
			$o.LogTo += "#"
		}
		
		if($Buffer) {
			$o.LogTo += "#BUFFER"
		}
		
		if($LogLevel){
			$o.LogLevel = $LogLevel;
		}
		
		if($Path){
			$o.LogTo += $Path;
		}
		
		if($BufferIsHost){
			$o | Invoke-Log "THIS WAS FORCED!" "PROGRESS" -ForceNoBuffer
		}
		
		#coloring test...
		$o | Invoke-Log "Color logging" "PROGRESS" -ForegroundColor "Red"; 
		
		#Identation
		$o | Invoke-Log "TESTING IDENTATION"
		$o | Invoke-Log "1" 		-RaiseIdent -SaveIdent "B_1.1"
		$o | Invoke-Log "1.1" 		-RaiseIdent -SaveIdent "B_1.1.1"
		$o | Invoke-Log "1.1.1"
		$o | Invoke-Log "1.1.2" 	-RaiseIdent 
		$o | Invoke-Log "1.1.2.1"	
		$o | Invoke-Log "1.1.3"		-DropIdent
		$o | Invoke-Log "1.2"		-ResetIdent "B_1.1.1"
		$o | Invoke-Log "2" 		-IdentLevel 0
		$o | Invoke-Log "3"
		
		#buffering (retain) test
		$o | Invoke-Log "Retained Start!!!" "PROGRESS" -Retain
	
		1..$RetainedCount | %{
			$TestLogLevel = Get-Random -Minimum 1 -Maximum 5	
			$o | Invoke-Log "Retained message $_ - LogLevel: $TestLogLevel " $TestLogLevel 
			Start-Sleep -s $RetainedInterval
		}
		
		$o | Invoke-Log "Flushed message" "PROGRESS" -Flush
		
		
		1..$LoggingNumber | %{
			$TestLogLevel = Get-Random -Minimum 1 -Maximum 5
			
			$fcolor = $null;
			$bcolor = $null;
			$fcolorText  = "";
			$bcolorText  = "";
			
			if($RandomColoring){
				$fcolor = @($RandomColoring,1) | Get-Random
				$fcolorText = "[F:$($fcolor)]"
			}
			
			if($RandomColoring){
				$bcolor = @($RandomColoring,1) | where {$_ -ne $fcolor} | Get-Random
				$bcolorText = "[B:$($bcolor)]"
			}
			
			
			if($fcolor -eq 1){
				$fcolor = $null;
				$fcolorText = ""
			}
			

			if($bcolor -eq 1){
				$bcolor = $null;
				$bcolorText = ""
			}
			
			$o | Invoke-Log " $fcolorText $bcolorText TestLog $_ LogLevel $TestLogLevel" $TestLogLevel -fcolor $fcolor -bcolor $bcolor
			
			Start-Sleep -s $BufferIsHostDelay
		}
		
		


	} finally {
		write-host ">>> LOGGIN TEST FINIHED. CHECK NEXT RESULTS."
		
		if($Path){
		write-host "------------ PATHS: "
			$Path | %{
				if(-not(Test-Path $_)){
					write-host "Log file inexistent: $_"
					continue;
				}
				
				$p = gi $_
				write-host "	$($p.FullName):"
				gci $p | %{write-host "		$($_.Name)"}
			}
		}
	
		if($o.outBuffer){
			write-host "------------ BUFFERED CONTENTS: "
			write-host ($o.outBuffer -join "`r`n")
		}
		
		$o = $null
	}
}