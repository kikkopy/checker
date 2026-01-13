Clear-Host

function Check-Username {
    param (
        [string]$Username
    )

    $url = "https://discord.com/api/v9/unique-username/username-attempt-unauthed"
    $body = @{ username = $Username } | ConvertTo-Json
    $headers = @{ "Content-Type" = "application/json" }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers -TimeoutSec 5
        return ($response.taken -eq $false)
    } catch {
        Write-Host "[ERREUR] $_" -ForegroundColor Red
        return $null
    }
}

function Send-Webhook {
    param (
        [string]$WebhookUrl,
        [string]$Username
    )

    $payload = @{
        content = "🚨 **$Username** est disponible !"
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -Headers @{ "Content-Type" = "application/json" }
}

Write-Host "=== Discord Username Checker ===" -ForegroundColor Cyan

while ($true) {
    $pseudo = Read-Host "Entrez un pseudo (ou 'exit' pour quitter)"
    if ($pseudo -eq "exit") {
        Write-Host "Arrêt du programme..." -ForegroundColor Yellow
        break
    }

    $loopCheck = Read-Host "Vérifier en boucle ? (y/N)"

    if ($loopCheck -eq "y") {
        $webhook = Read-Host "Entrez l'URL du webhook Discord"

        Write-Host "Vérification en boucle lancée pour $pseudo..." -ForegroundColor Cyan

        while ($true) {
            $result = Check-Username -Username $pseudo

            if ($result -eq $true) {
                Write-Host "[DISPO] $pseudo est disponible !" -ForegroundColor Green
                Send-Webhook -WebhookUrl $webhook -Username $pseudo
                break
            } elseif ($result -eq $false) {
                Write-Host "[PRIS] $pseudo est pris, nouvelle tentative..." -ForegroundColor DarkRed
            } else {
                Write-Host "[ERREUR] Vérification impossible, retry..." -ForegroundColor Magenta
            }

            $delay = Get-Random -Minimum 5 -Maximum 9
            Start-Sleep -Seconds $delay
        }

    } else {
        $result = Check-Username -Username $pseudo

        if ($result -eq $true) {
            Write-Host "[DISPO] $pseudo est disponible !" -ForegroundColor Green
        } elseif ($result -eq $false) {
            Write-Host "[PRIS] $pseudo est déjà pris." -ForegroundColor Red
        } else {
            Write-Host "[ERREUR] Impossible de vérifier $pseudo." -ForegroundColor Magenta
        }
    }
}
