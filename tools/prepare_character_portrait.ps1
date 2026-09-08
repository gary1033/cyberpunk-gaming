# Prepare an image_gen portrait; the input file is never changed.
# Usage: .\tools\prepare_character_portrait.ps1 -InputPath raw.png -OutputPath portrait.png
# Inspect an existing PNG: -InputPath portrait.png -Inspect
# Run the small in-memory regression check: -SelfTest
# Use -RemoveEnclosedKey only when the generation prompt forbids key-green subject materials.
# Use -AllowBottomCrop only for visually checked half-body art with complete hair and shoulders.
[CmdletBinding(DefaultParameterSetName = 'Prepare')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Prepare')]
    [Parameter(Mandatory, ParameterSetName = 'Inspect')]
    [string]$InputPath,
    [Parameter(Mandatory, ParameterSetName = 'Prepare')]
    [string]$OutputPath,
    [Parameter(ParameterSetName = 'Prepare')]
    [switch]$RemoveEnclosedKey,
    [Parameter(ParameterSetName = 'Prepare')]
    [switch]$AllowBottomCrop,
    [Parameter(Mandatory, ParameterSetName = 'Inspect')]
    [switch]$Inspect,
    [Parameter(Mandatory, ParameterSetName = 'SelfTest')]
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
if (-not ('NeonPortrait' -as [type])) {
    $drawingReferences = @([System.Drawing.Bitmap].Assembly.Location) +
        @([System.Drawing.Bitmap].Assembly.GetReferencedAssemblies() | ForEach-Object Name)
    Add-Type -ReferencedAssemblies $drawingReferences -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public sealed class PortraitStats {
    public int Width, Height, TransparentPixels, PartialPixels, OpaquePixels;
    public string PixelFormat;
    public int[] CornerAlpha, BoundingBox;
    public bool Ready;
}

public static class NeonPortrait {
    const int Width = 1024, Height = 1536;

    static byte[] Read(Bitmap image) {
        byte[] pixels = new byte[image.Width * image.Height * 4];
        BitmapData data = image.LockBits(new Rectangle(0, 0, image.Width, image.Height),
            ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        try {
            for (int y = 0; y < image.Height; y++)
                Marshal.Copy(IntPtr.Add(data.Scan0, y * data.Stride), pixels, y * image.Width * 4, image.Width * 4);
        } finally { image.UnlockBits(data); }
        return pixels;
    }

    static void Write(Bitmap image, byte[] pixels) {
        BitmapData data = image.LockBits(new Rectangle(0, 0, image.Width, image.Height),
            ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
        try {
            for (int y = 0; y < image.Height; y++)
                Marshal.Copy(pixels, y * image.Width * 4, IntPtr.Add(data.Scan0, y * data.Stride), image.Width * 4);
        } finally { image.UnlockBits(data); }
    }

    public static PortraitStats Analyze(Bitmap image) {
        byte[] pixels = Read(image);
        int w = image.Width, h = image.Height, left = w, top = h, right = -1, bottom = -1;
        PortraitStats stats = new PortraitStats { Width = w, Height = h, PixelFormat = image.PixelFormat.ToString() };
        for (int n = 0; n < w * h; n++) {
            int alpha = pixels[n * 4 + 3];
            if (alpha == 0) stats.TransparentPixels++;
            else {
                if (alpha == 255) stats.OpaquePixels++; else stats.PartialPixels++;
                left = Math.Min(left, n % w); right = Math.Max(right, n % w);
                top = Math.Min(top, n / w); bottom = Math.Max(bottom, n / w);
            }
        }
        stats.CornerAlpha = new int[] { pixels[3], pixels[(w - 1) * 4 + 3],
            pixels[(h - 1) * w * 4 + 3], pixels[(w * h - 1) * 4 + 3] };
        stats.BoundingBox = right < 0 ? new int[] { 0, 0, 0, 0 } :
            new int[] { left, top, right - left + 1, bottom - top + 1 };
        stats.Ready = image.PixelFormat == PixelFormat.Format32bppArgb &&
            w == Width && h == Height && CornersClear(stats) &&
            stats.TransparentPixels > 0 && stats.OpaquePixels > 0;
        return stats;
    }

    static bool CornersClear(PortraitStats stats, bool allowBottomCrop = false) {
        for (int i = 0; i < (allowBottomCrop ? 2 : 4); i++) if (stats.CornerAlpha[i] != 0) return false;
        return true;
    }

    static bool IsKey(byte[] pixels, int n) {
        // Actual image_gen flat borders vary by up to 39/255; never broaden this to all green.
        int i = n * 4;
        return pixels[i] <= 48 && pixels[i + 1] >= 207 && pixels[i + 2] <= 48;
    }

    static void Enqueue(byte[] pixels, int n, bool[] removed, int[] queue, ref int tail) {
        if (!removed[n] && IsKey(pixels, n)) {
            removed[n] = true;
            queue[tail++] = n;
        }
    }

    static void RemoveKey(Bitmap image, bool removeEnclosedKey = false, bool allowBottomCrop = false) {
        int w = image.Width, h = image.Height;
        byte[] pixels = Read(image);
        for (int n = 0; n < w * h; n++) {
            bool requiredBorder = n < w || (!allowBottomCrop && n >= w * (h - 1)) ||
                ((n % w == 0 || n % w == w - 1) && (!allowBottomCrop || n / w < h * 0.60));
            if (requiredBorder && !IsKey(pixels, n))
                throw new InvalidOperationException("Opaque input requires a flat #00FF00 border; regenerate this image.");
        }
        bool[] removed = new bool[w * h];
        int[] queue = new int[w * h];
        int head = 0, tail = 0;
        for (int x = 0; x < w; x++) {
            Enqueue(pixels, x, removed, queue, ref tail);
            Enqueue(pixels, (h - 1) * w + x, removed, queue, ref tail);
        }
        for (int y = 0; y < h; y++) {
            Enqueue(pixels, y * w, removed, queue, ref tail);
            Enqueue(pixels, y * w + w - 1, removed, queue, ref tail);
        }
        // ponytail: edge-connected color key cannot separate a same-green garment
        // touching the backdrop; regenerate with a distinct garment color in that case.
        while (head < tail) {
            int n = queue[head++], x = n % w, y = n / w;
            if (x > 0) Enqueue(pixels, n - 1, removed, queue, ref tail);
            if (x + 1 < w) Enqueue(pixels, n + 1, removed, queue, ref tail);
            if (y > 0) Enqueue(pixels, n - w, removed, queue, ref tail);
            if (y + 1 < h) Enqueue(pixels, n + w, removed, queue, ref tail);
        }
        // Explicit opt-in for new no-key-green character art also clears gaps between limbs.
        // Existing alpha art never enters this path; default mode retains enclosed green materials.
        if (removeEnclosedKey)
            for (int n = 0; n < w * h; n++) if (IsKey(pixels, n)) removed[n] = true;
        for (int n = 0; n < w * h; n++) {
            int i = n * 4;
            if (removed[n]) { pixels[i] = pixels[i + 1] = pixels[i + 2] = pixels[i + 3] = 0; continue; }
            bool edge = (n % w > 0 && removed[n - 1]) || (n % w + 1 < w && removed[n + 1]) ||
                (n >= w && removed[n - w]) || (n + w < w * h && removed[n + w]);
            // Antialiasing can span two pixels; restrict despill to that boundary
            // so legitimate interior green eyes, hair and fabrics stay opaque.
            if (!edge && removeEnclosedKey) {
                for (int dy = -2; dy <= 2 && !edge; dy++)
                    for (int dx = -2; dx <= 2 && !edge; dx++) {
                        int x = n % w + dx, y = n / w + dy;
                        if (x >= 0 && x < w && y >= 0 && y < h) edge = removed[y * w + x];
                    }
            }
            int nonGreen = Math.Max(pixels[i], pixels[i + 2]);
            if (edge && pixels[i + 1] > nonGreen + 16) {
                int alpha = (int)Math.Round(255.0 * (255 - pixels[i + 1]) / (255 - nonGreen));
                pixels[i + 3] = (byte)(alpha < 8 ? 0 : alpha);
                if (alpha > 0) {
                    pixels[i] = (byte)Math.Min(255, pixels[i] * 255 / alpha);
                    pixels[i + 2] = (byte)Math.Min(255, pixels[i + 2] * 255 / alpha);
                }
                pixels[i + 1] = Math.Max(pixels[i], pixels[i + 2]);
            }
        }
        Write(image, pixels);
    }

    public static Bitmap Prepare(Bitmap input, bool removeEnclosedKey = false, bool allowBottomCrop = false) {
        using (Bitmap image = input.Clone(new Rectangle(0, 0, input.Width, input.Height), PixelFormat.Format32bppArgb)) {
            PortraitStats before = Analyze(image);
            if (before.TransparentPixels > 0 || before.PartialPixels > 0) {
                if (!CornersClear(before, allowBottomCrop))
                    throw new InvalidOperationException("Alpha input has nontransparent corners; regenerate or inspect its framing.");
            } else RemoveKey(image, removeEnclosedKey, allowBottomCrop);
            PortraitStats keyed = Analyze(image);
            if (!CornersClear(keyed, allowBottomCrop) || keyed.TransparentPixels == 0 || keyed.OpaquePixels == 0)
                throw new InvalidOperationException("No valid transparent portrait remains; output was not written.");
            int[] box = keyed.BoundingBox;
            double scale = Math.Min(Width * 0.90 / box[2], Height * 0.90 / box[3]);
            int drawWidth = Math.Max(1, (int)Math.Round(box[2] * scale));
            int drawHeight = Math.Max(1, (int)Math.Round(box[3] * scale));
            Bitmap output = new Bitmap(Width, Height, PixelFormat.Format32bppArgb);
            using (Graphics graphics = Graphics.FromImage(output)) {
                graphics.Clear(Color.Transparent);
                graphics.CompositingMode = CompositingMode.SourceCopy;
                graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
                graphics.DrawImage(image, new Rectangle((Width - drawWidth) / 2, (Height - drawHeight) / 2, drawWidth, drawHeight),
                    box[0], box[1], box[2], box[3], GraphicsUnit.Pixel);
            }
            if (!Analyze(output).Ready) {
                output.Dispose();
                throw new InvalidOperationException("Prepared portrait failed RGBA/alpha validation.");
            }
            return output;
        }
    }

    static void ExpectRejected(Bitmap image) {
        try { using (Bitmap ignored = Prepare(image)) { } }
        catch (InvalidOperationException) { return; }
        throw new Exception("SelfTest: invalid input was accepted.");
    }

    public static string SelfTest() {
        using (Bitmap source = new Bitmap(80, 120, PixelFormat.Format32bppArgb)) {
            using (Graphics g = Graphics.FromImage(source)) {
                g.Clear(Color.Lime);
                g.FillRectangle(Brushes.Black, 20, 15, 40, 90);
                g.FillRectangle(Brushes.Lime, 30, 30, 20, 40);
            }
            source.SetPixel(19, 50, Color.FromArgb(0, 128, 0));
            using (Bitmap keyed = (Bitmap)source.Clone()) {
                RemoveKey(keyed);
                if (keyed.GetPixel(40, 40).ToArgb() != Color.Lime.ToArgb() || keyed.GetPixel(0, 0).A != 0)
                    throw new Exception("SelfTest: enclosed green clothing or background mask failed.");
                Color edge = keyed.GetPixel(19, 50);
                if (edge.A < 100 || edge.A > 150 || edge.G > 5)
                    throw new Exception("SelfTest: antialiased green edge was not cleaned.");
                using (Bitmap prepared = Prepare(keyed)) {
                    PortraitStats stats = Analyze(prepared);
                    if (!stats.Ready || stats.BoundingBox[0] < 45 || stats.BoundingBox[1] < 70)
                        throw new Exception("SelfTest: native alpha, output size, or safety margin failed.");
                }
            }
            using (Bitmap prepared = Prepare(source)) {
                if (!Analyze(prepared).Ready || source.GetPixel(0, 0).A != 255)
                    throw new Exception("SelfTest: chroma preparation changed the input.");
            }
            using (Bitmap enclosed = (Bitmap)source.Clone()) {
                Color emerald = Color.FromArgb(18, 90, 45);
                enclosed.SetPixel(25, 25, emerald);
                RemoveKey(enclosed, true);
                if (enclosed.GetPixel(40, 40).A != 0 || enclosed.GetPixel(25, 25).ToArgb() != emerald.ToArgb())
                    throw new Exception("SelfTest: enclosed background removal changed legitimate green material.");
            }
            source.SetPixel(0, 0, Color.FromArgb(29, 223, 39));
            using (Bitmap prepared = Prepare(source)) {
                if (!Analyze(prepared).Ready) throw new Exception("SelfTest: observed near-green border was rejected.");
            }
            using (Graphics g = Graphics.FromImage(source)) { g.FillRectangle(Brushes.Black, 20, 100, 40, 20); }
            ExpectRejected(source);
            using (Bitmap prepared = Prepare(source, true, true)) {
                if (!Analyze(prepared).Ready) throw new Exception("SelfTest: approved half-body bottom crop failed.");
            }
            source.SetPixel(0, 0, Color.Black);
            ExpectRejected(source);
            source.SetPixel(0, 0, Color.Transparent);
            ExpectRejected(source);
            using (Graphics g = Graphics.FromImage(source)) { g.Clear(Color.Lime); }
            ExpectRejected(source);
        }
        return "PASS: chroma removal, enclosed green preservation, native alpha, input preservation, 1024x1536 margins, invalid borders, invalid alpha, and empty images.";
    }
}
'@
}

if ($SelfTest) { [NeonPortrait]::SelfTest(); return }
$resolvedInput = (Resolve-Path -LiteralPath $InputPath).ProviderPath
$sourceImage = [System.Drawing.Bitmap]::new($resolvedInput)
try {
    if ($Inspect) { [NeonPortrait]::Analyze($sourceImage); return }
    $resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    if ([string]::Equals($resolvedInput, $resolvedOutput, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'InputPath and OutputPath must differ; the original image must be retained.'
    }
    if ([IO.Path]::GetExtension($resolvedOutput) -ine '.png') { throw 'OutputPath must end in .png.' }
    $preparedImage = [NeonPortrait]::Prepare($sourceImage, $RemoveEnclosedKey.IsPresent, $AllowBottomCrop.IsPresent)
    try {
        $outputFolder = [IO.Path]::GetDirectoryName($resolvedOutput)
        [IO.Directory]::CreateDirectory($outputFolder) | Out-Null
        $stagingPath = Join-Path $outputFolder ('.portrait-' + [guid]::NewGuid().ToString('N') + '.png')
        try {
            $preparedImage.Save($stagingPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $encoded = [System.Drawing.Bitmap]::new($stagingPath)
            try {
                $stats = [NeonPortrait]::Analyze($encoded)
                if (-not $stats.Ready) { throw 'Encoded PNG failed transparency validation.' }
            } finally { $encoded.Dispose() }
            Move-Item -LiteralPath $stagingPath -Destination $resolvedOutput -Force
            [pscustomobject]@{ InputPath = $resolvedInput; OutputPath = $resolvedOutput; Validation = $stats }
        } finally {
            if (Test-Path -LiteralPath $stagingPath) { Remove-Item -LiteralPath $stagingPath }
        }
    } finally { $preparedImage.Dispose() }
} finally { $sourceImage.Dispose() }
