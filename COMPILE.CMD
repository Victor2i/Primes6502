@echo off
vasm6502 -Fbin -dotdir MAIN.TXT -o OUT.PRG
vasm6502 -Fbin -dotdir MERGE.TXT -o OUTPUT.NES
echo Done. Press any key to close.
pause>NUL