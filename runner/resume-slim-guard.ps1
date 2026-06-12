# Fired by Task Scheduler from 05:25 every 30 min: resumes the slim benchmark pipeline
# after a rate-limit kill. Guards make it a no-op while the pipeline is alive or finished,
# so it is safe to fire at any time (incl. the registration test-fire).
$log = 'C:\Users\Ivan\.claude\slim-resume.log'
"[$(Get-Date -Format o)] fired" | Add-Content $log
$pipeLog = 'C:\Users\Ivan\AppData\Local\Temp\bench-slim.log'

if (Test-Path $pipeLog) {
    $tail = Get-Content $pipeLog -Tail 10 -ErrorAction SilentlyContinue
    if ($tail -match 'ALL DONE') {
        "  -> pipeline already complete, no action" | Add-Content $log
        exit 0
    }
    if ((Get-Item $pipeLog).LastWriteTime -gt (Get-Date).AddMinutes(-5)) {
        "  -> pipeline alive (log fresh), no action" | Add-Content $log
        exit 0
    }
}

"  -> pipeline stalled or dead: resuming (idempotent driver)" | Add-Content $log
& 'C:\Program Files\Git\bin\bash.exe' -c 'cd /c/Users/Ivan/repos/distill-benchmark && bash runner/run-slim-2026-06-13.sh >> /tmp/bench-slim.log 2>&1'
"[$(Get-Date -Format o)] resume attempt exited $LASTEXITCODE" | Add-Content $log
