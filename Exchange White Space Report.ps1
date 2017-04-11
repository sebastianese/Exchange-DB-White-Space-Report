Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
#region Variables and Arguments
$users = "User <user@something.com>" # List of users to email your report to (separate by comma)
$fromemail = "Exchange White Space Monitor <user@something.com>"
$server = "yourSMTP.com" #enter your own SMTP server DNS name / IP address here
$WhiteSpace = Get-MailboxDatabase -Status | sort name | select name,@{Name='DB Size (Gb)';Expression={$_.DatabaseSize.ToGb()}},@{Name='Available New Mbx Space Gb)';Expression={$_.AvailableNewMailboxSpace.ToGb()}} | ConvertTo-Html
$DbLocation = Get-MailboxDatabase | Select-Object Id,EdbFilePath | ConvertTo-Html -Fragment
$DiskSpace = gwmi win32_volume -Filter ‘drivetype = 3’ | select Driveletter,Label,@{LABEL=’GBfreespace’;EXPRESSION={$_.freespace/1GB} } | ConvertTo-Html -Fragment
$CurrentTime = Get-Date 

# Email our report out
send-mailmessage -from $fromemail  -to $users -subject "Database White Space Report Generated on $CurrentTime " -BodyAsHtml "<p><h2>Available White Space On Each DB</p></h2>$WhiteSpace <p><h2>Database Location</p></h2>$DbLocation <p><h2>Free Space For Each Partition (Not Counting White Space)</p></h2>$DiskSpace" -priority Normal -smtpServer $server