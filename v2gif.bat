@echo off
::quality config
set skip_compress=false
set fps=15
set png_quality=0-50
set png_speed=3
set gif_scale=320:-1
::stats_mode=full/diff
set palette_gen=palettegen=stats_mode=diff
::dither=sierra2/bayer/floyd_steinberg/sierra2_4a/none
::bayer:bayer_scale=1/2/3
set palette_use=paletteuse=dither=floyd_steinberg
::end config

set bat_dir=%~dp0
set tmp_file_parameter=%%09d
set ext=cmpt
set filters=fps=%fps%,scale=%gif_scale%:flags=lanczos
set palette=palette.%1.png
set extractDir=extract.%1
set output=%1-v2gif.gif
if %skip_compress%==false (goto a1) else (goto a2)
:a1
echo 1/6.creating palette file:%palette%%...
%bat_dir%\ffmpeg -v warning -i %1 -vf "%filters%,%palette_gen%" -y %palette%
echo 2/6.extracting to png...
mkdir %extractDir%
%bat_dir%\ffmpeg -v warning -i %1 -i %palette% -lavfi "%filters% [x]; [x][1:v] %palette_use%" %extractDir%\%tmp_file_parameter%.png
pause
echo 3/6.compressing png...
for %%i in (%extractDir%\*.png) do (start /b %bat_dir%\pngquant.exe --force --strip --ext -%ext%.png --speed=%png_speed% --quality=%png_quality% %%i)
echo 4/6.split compressed png...
cd %extractDir%
mkdir %ext%
move *%ext%.png %ext%
cd ..
echo 5/6.assembly gif...
%bat_dir%\ffmpeg -v warning -framerate %fps% -i %extractDir%\%ext%\%tmp_file_parameter%-%ext%.png %output%
echo 6/6.cleanup...
del %palette%
rd /s /q %extractDir%

:a2
if %skip_compress%==true (goto a3) else (goto a4)
:a3
echo 1/3.creating palette file:%palette%%...
%bat_dir%\ffmpeg -v warning -i %1 -vf "%filters%,%palette_gen%" -y %palette%
echo 2/3.encodeing gif...
%bat_dir%\ffmpeg -v warning -i %1 -i %palette% -lavfi "%filters% [x]; [x][1:v] %palette_use%" %output%
echo 3/3.cleanup...
del %palette%
:a4
echo ///All Done!