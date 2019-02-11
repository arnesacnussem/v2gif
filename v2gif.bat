@echo off
::quality config
set fps=10
set png_quality=0-20
set png_speed=3
set gif_scale=240:-1
::end config

set filters=fps=%fps%,scale=%gif_scale%:flags=lanczos
set palette=palette.%1.png
set extractDir=extract.%1

echo 0.creating palette file:%palette%%...
ffmpeg -v warning -i %1 -vf "%filters%,palettegen" -y %palette%
echo 0.palette done!

echo 1.extracting to png...

mkdir %extractDir%
ffmpeg -v warning -i %1 -i %palette% -lavfi "%filters% [x]; [x][1:v] paletteuse" %extractDir%\%%03d.png
echo 1.extract done!

echo 2.compressing png...
for %%i in (%extractDir%\*.png) do (
start /b pngquant.exe --force --strip --speed=%png_speed% --quality=%png_quality% %%i)
echo 2.compress done!

echo 3.split compressed png...
cd %extractDir%
mkdir fs8
move *-fs8.png fs8
cd ..
echo 3.split done!

echo 4.assembly gif...
ffmpeg -v warning -framerate %fps% -i %extractDir%\fs8\%%03d-fs8.png gif-%1.gif
echo 4.assembly done!
del %palette%
rd /s /q %extractDir%