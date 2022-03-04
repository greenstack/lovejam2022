tar.exe --exclude="bin/*" --exclude="*.bat" --exclude="*.aseprite" -a -c -f bin/%1%.love .
copy /b "C:\Program Files\LOVE\love.exe"+%1%.love "bin/%1%.exe"
