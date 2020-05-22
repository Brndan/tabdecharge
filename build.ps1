# Construire le programme sous Windows
# Pas de maintenance prévue du script

$now = Get-Date -UFormat "%Y-%m-%d_%T"
$sha1 = (git rev-parse --short HEAD).Trim()

go build -ldflags "-X main.sha1ver=$sha1 -X main.buildTime=$now -w -s"
