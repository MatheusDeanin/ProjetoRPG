param([Parameter(Mandatory=$true)][string]$RunSource, [int]$RunRows = 2, [int]$CellSize = 256, [int]$CharacterHeight = 192)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$projectRoot = Split-Path $PSScriptRoot -Parent
$outputRoot = Join-Path $projectRoot 'Assets/Hero/Prepared'
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
if ($CellSize -lt 32 -or $CharacterHeight -le 0 -or $CharacterHeight -gt ($CellSize - 16)) {
    throw 'CharacterHeight must fit inside CellSize with transparent margins.'
}

function Export-Sprites([string]$Source, [string]$Name, [int]$Expected, [int]$Rows = 1) {
    $sourceImage = [System.Drawing.Bitmap]::new($Source)
    try {
        $ranges = @()
        for ($row = 0; $row -lt $Rows; $row++) {
        $rowTop = [int]($row * $sourceImage.Height / $Rows)
        $rowBottom = [int](($row + 1) * $sourceImage.Height / $Rows)
        $start = -1
        for ($x = 0; $x -le $sourceImage.Width; $x++) {
            $count = 0
            if ($x -lt $sourceImage.Width) {
                for ($y = $rowTop; $y -lt $rowBottom; $y++) {
                    if ($sourceImage.GetPixel($x, $y).A -gt 40) { $count++ }
                }
            }
            if ($count -ge 3) {
                if ($start -lt 0) { $start = $x }
            } elseif ($start -ge 0) {
                if (($x - $start) -gt 10) { $ranges += ,@($start, ($x - 1), $rowTop, $rowBottom) }
                $start = -1
            }
        }
        }
        if ($ranges.Count -ne $Expected) { throw "$Name has $($ranges.Count) silhouettes; expected $Expected. Inspect before exporting." }
        $boxes = @()
        foreach ($range in $ranges) {
            $top = $sourceImage.Height
            $bottom = 0
            for ($x = $range[0]; $x -le $range[1]; $x++) {
                for ($y = $range[2]; $y -lt $range[3]; $y++) {
                    if ($sourceImage.GetPixel($x, $y).A -gt 40) {
                        $top = [Math]::Min($top, $y)
                        $bottom = [Math]::Max($bottom, $y)
                    }
                }
            }
            $boxes += [System.Drawing.Rectangle]::new($range[0], $top, ($range[1]-$range[0]+1), ($bottom-$top+1))
        }
        # One scale per sequence preserves relative frame dimensions.
        $maxHeight = ($boxes | ForEach-Object Height | Measure-Object -Maximum).Maximum
        $maxWidth = ($boxes | ForEach-Object Width | Measure-Object -Maximum).Maximum
        $scale = [Math]::Min([double]$CharacterHeight / $maxHeight, ($CellSize - 32.0) / $maxWidth)
        $sheet = [System.Drawing.Bitmap]::new($CellSize*$Expected, $CellSize)
        $sheetGraphics = [System.Drawing.Graphics]::FromImage($sheet)
        $frameFolder = Join-Path $outputRoot $Name
        New-Item -ItemType Directory -Force -Path $frameFolder | Out-Null
        try {
            for ($i=0; $i -lt $Expected; $i++) {
                $box = $boxes[$i]
                $width = [int][Math]::Round($box.Width*$scale)
                $height = [int][Math]::Round($box.Height*$scale)
                $frame = [System.Drawing.Bitmap]::new($CellSize,$CellSize)
                $graphics = [System.Drawing.Graphics]::FromImage($frame)
                try {
                    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                    $baseline = $CellSize - [int][Math]::Round($CellSize / 8.0)
                    $destination = [System.Drawing.Rectangle]::new([int][Math]::Floor(($CellSize-$width)/2), ($baseline-$height), $width, $height)
                    $graphics.DrawImage($sourceImage, $destination, $box, [System.Drawing.GraphicsUnit]::Pixel)
                    $frame.Save((Join-Path $frameFolder ('{0}_{1:D2}.png' -f $Name,($i+1))), [System.Drawing.Imaging.ImageFormat]::Png)
                    $sheetGraphics.DrawImageUnscaled($frame, $CellSize*$i, 0)
                } finally { $graphics.Dispose(); $frame.Dispose() }
            }
            $sheet.Save((Join-Path $outputRoot ('hero_'+$Name+'.png')), [System.Drawing.Imaging.ImageFormat]::Png)
        } finally { $sheetGraphics.Dispose(); $sheet.Dispose() }
        Write-Output "$Name : $Expected frames, ${CellSize}x${CellSize} cells, transparent PNG."
    } finally { $sourceImage.Dispose() }
}
Export-Sprites (Join-Path $projectRoot 'Assets/Hero/Original/hero_idle.png') 'idle' 6
Export-Sprites ([System.IO.Path]::GetFullPath($RunSource)) 'run' 8 $RunRows
