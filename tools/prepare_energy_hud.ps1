# Key the image_gen green backdrop, preserve the chassis, and fit it into 512x96.
param([Parameter(Mandatory)][string]$InputPath, [Parameter(Mandatory)][string]$OutputPath)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$drawingReferences = @([System.Drawing.Bitmap].Assembly.Location) +
    @([System.Drawing.Bitmap].Assembly.GetReferencedAssemblies() | ForEach-Object Name)
Add-Type -ReferencedAssemblies $drawingReferences -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
public static class EnergyFramePrep {
    public static void Run(string input, string output) {
        using (var source = new Bitmap(input))
        using (var keyed = new Bitmap(source.Width, source.Height, PixelFormat.Format32bppArgb)) {
            int left=source.Width, top=source.Height, right=-1, bottom=-1;
            // The generation spec excludes green chassis materials. Cyan and magenta stay opaque.
            for (int y=0; y<source.Height; y++) for (int x=0; x<source.Width; x++) {
                Color c = source.GetPixel(x,y);
                bool key = c.G > 110 && c.G > c.R+70 && c.G > c.B+70;
                if (key || c.A == 0) continue;
                int other = Math.Max(c.R,c.B);
                if (c.G > other+16) c = Color.FromArgb(c.A,c.R,other,c.B);
                keyed.SetPixel(x,y,c);
                left=Math.Min(left,x); top=Math.Min(top,y); right=Math.Max(right,x); bottom=Math.Max(bottom,y);
            }
            if (right<left || left==0 || top==0 || right==source.Width-1 || bottom==source.Height-1)
                throw new InvalidOperationException("Expected an isolated chassis with a removable green border.");
            Rectangle crop = Rectangle.FromLTRB(left,top,right+1,bottom+1);
            float scale = Math.Min(480f/crop.Width,64f/crop.Height);
            float w=crop.Width*scale, h=crop.Height*scale;
            using (var result = new Bitmap(512,96,PixelFormat.Format32bppArgb)) {
                using (var g = Graphics.FromImage(result)) {
                    g.Clear(Color.Transparent);
                    g.CompositingMode=CompositingMode.SourceCopy;
                    g.InterpolationMode=InterpolationMode.HighQualityBicubic;
                    g.PixelOffsetMode=PixelOffsetMode.HighQuality;
                    g.DrawImage(keyed,new RectangleF((512-w)/2,(96-h)/2,w,h),crop,GraphicsUnit.Pixel);
                }
                result.Save(output,ImageFormat.Png);
            }
        }
    }
}
'@
[EnergyFramePrep]::Run([IO.Path]::GetFullPath($InputPath), [IO.Path]::GetFullPath($OutputPath))
