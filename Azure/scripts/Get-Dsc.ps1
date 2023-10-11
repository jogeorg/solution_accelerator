<#
 .Synopsis
  Gets the DSC configuration .ZIP folder from a storage account and executes the DSC configs

 .Description
  A more detailed way to say "Gets the DSC configuration .ZIP folder from a storage account and executes the DSC configs"

 .Parameter stIdentifier
   The storage account with the DSC container, defaults to 'core'

 .Parameter container
   The storage account container with the DSC configs, defaults to 'dsc'

 .Example
   # Show a default display of this month.
   Get-Dsc.ps1

 .Example
   # Show a default display of this month.
   Get-Dsc.ps1 -stIdentifier "core"

 .Example
   # Show a default display of this month.
   Get-Dsc.ps1 -container "dsc"

 .Example
   # Show a default display of this month.
   Get-Dsc.ps1 -stIdentifier "core" -container "dsc"

 .LINK
   https://www.youtube.com/watch?v=dQw4w9WgXcQ
#>


param(
    $stIdentifier = 'core',
    $container = 'dsc'
)

try{
    $rg = get-azresourcegroup | Where-Object {$_.ResourceGroupName -match $stIdentifier}
    $storageAccountName = get-azStorageAccount | Where-Object {$_.ResourceGroupName -match $rg.ResourceGroupName}
    $key = (Get-AzStorageAccountKey -ResourceGroupName $rg.ResourceGroupName -Name $storageAccountName.StorageAccountName).Value[0]
    $ctx = New-AzStorageContext -StorageAccountName $StorageAccountName.StorageAccountName -StorageAccountKey $key
    $blobs = Get-AzStorageBlob -Container $container -Blob * -context $ctx -TagCondition """latest""='true'"
    foreach ($blob in $blobs) {
      Get-AzStorageBlobContent -blob $blob.Name -container $container -Destination 'C:\Temp' -context $ctx
    }
    
    $fpath = Get-ChildItem C:\Temp\*.zip 
    Expand-Archive -Path $fpath.FullName -DestinationPath 'C:\Temp' -force

    powershell.exe -file C:\Temp\Start-SSBA.ps1
}
catch { 
    Write-Host "An error occurred:"
    Write-Host $_
    Write-Host $_.ScriptStackTrace
}