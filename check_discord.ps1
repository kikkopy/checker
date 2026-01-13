# Discord Username Checker PS1
Clear-Host

function Check-Username {
    param (
        [string]$Username
    )
    
    $url = "https://discord.com/api/v9/unique-username/username-attempt-unauthed"
    $body = @{ "username" = $Username } | ConvertTo-Json
    $headers = @{ "Content-Type" = "application/json" }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers -TimeoutSec 5
        if ($response.taken -eq $false) {
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Host "[ERREUR] $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "=== Discord Username Checker ===" -ForegroundColor Cyan

while ($true) {
    $pseudo = Read-Host "Entrez un pseudo (ou 'exit' pour quitter)"
    
    if ($pseudo -eq "exit") {
        Write-Host "Arrêt du programme..." -ForegroundColor Yellow
        break
    }

    $result = Check-Username -Username $pseudo

    if ($result -eq $true) {
        Write-Host "[DISPO] $pseudo est disponible !" -ForegroundColor Green
    } elseif ($result -eq $false) {
        Write-Host "[PRIS] $pseudo est déjà pris." -ForegroundColor Red
    } else {
        Write-Host "[ERREUR] Impossible de vérifier $pseudo." -ForegroundColor Magenta
    }
}
