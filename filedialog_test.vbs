option explicit

function echo(a):echo=WScript.Echo(a):end function
function quit(a):quit=WScript.Quit(a):end function

' good old WScript.Shell to the rescue again
dim wShell: set wShell=CreateObject("WScript.Shell")
dim fso: set fso=CreateObject("Scripting.FileSystemObject")

dim ScriptHost: ScriptHost=fso.GetFileName(WScript.FullName)
ScriptHost=LCase(Left(ScriptHost, Len(ScriptHost)-4))

quit main
function main()
    'echo "Hello World!"
    'echo ScriptHost
    ' this works, but shows "upload file" instead of save as, and requires the user to select an existing file
    'Set wShell=CreateObject("WScript.Shell")
    'Set oExec=wShell.Exec("mshta.exe ""about:<input type=file id=FILE><script>FILE.click();new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);close();resizeTo(0,0);</script>""")
    'sFileSelected = oExec.StdOut.ReadLine
    'echo sFileSelected
    ' https://stackoverflow.com/a/18309009
    dim arch
    if InStr(LCase(WScript.FullName), "syswow64") then
        'echo "syswow64 in path"
        arch="x86"
    else
        'echo "syswow64 not in path"
        dim envSystem: set envSystem=wShell.Environment("System")
        'echo LCase(envSystem("PROCESSOR_ARCHITECTURE"))
        arch=LCase(envSystem("PROCESSOR_ARCHITECTURE"))
    end if
    'echo WScript.FullName
    dim result
    if arch = "x86" then
        'echo "using MSComDlg.CommonDialog"
        result=filedialog("CSV files (*.csv)|*.csv|All Files (*.*)|*.*", "csv", "Save As CSV", true)
    else
        'echo "using powershell"
        result=psfiledialog("CSV files (*.csv)|*.csv|All Files (*.*)|*.*", "csv", "Save As CSV", true)
    end if
    if result = "" then
        echo "user clicked cancel or close"
    else
        echo "user entered:" & vbCrLf & """" & result & """"
    end if
    main = 0
end function

' https://stackoverflow.com/a/17997612
' MSComDlg.CommonDialog only works on x86, the function fails on x64
function filedialog(filt, def, title, save)
    dim dlg: set dlg = CreateObject("MSComDlg.CommonDialog")
    dlg.MaxFileSize = 256
    if filt = "" then
        dlg.Filter = "All Files (*.*)|*.*"
    else
        dlg.Filter = filt
    end if
    dlg.FilterIndex = 1
    dlg.DialogTitle = title
    dlg.InitDir = wShell.SpecialFolders("MyDocuments")
    dlg.FileName = ""
    if save = true then
        dlg.DefaultExt = def
        dlg.Flags = &H800 + &H4
        discard = dlg.ShowSave()
    else
        dlg.Flags = &H1000 + &H4 + &H800
        dim discard: discard = dlg.ShowOpen()
    end if
    filedialog = dlg.FileName
end function

' https://stackoverflow.com/a/56740935
' use powershell to do our bidding, it's slower but works on both x64 and x86
function psfiledialog(filt, def, title, save)
    dim psScript: psScript="[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')|Out-Null;"
    if save = true then
        psScript=psScript & "$dlg=New-Object System.Windows.Forms.SaveFileDialog;"
        psScript=psScript & "$dlg.DefaultExt='" & def & "';"
    else
        psScript=psScript & "$dlg=New-Object System.Windows.Forms.OpenFileDialog;"
    end if
    if filt = "" then
        psScript=psScript & "$dlg.Filter='All Files (*.*)|*.*';"
    else
        psScript=psScript & "$dlg.Filter='" & filt & "';"
    end if
    psScript=psScript & "$dlg.FilterIndex=1;"
    psScript=psScript & "$dlg.Title='" & Replace(title,"'","''") & "';"
    psScript=psScript & "$dlg.initialDirectory=[Environment]::GetFolderPath('MyDocuments');"
    psScript=psScript & "$dlg.ShowDialog()|Out-Null;"
    psScript=psScript & "Write-Host $dlg.FileName;"
    dim psCommand: psCommand="powershell -NoLogo -NoProfile -ExecutionPolicy RemoteSigned"
    if ScriptHost <> "cscript" then
        psCommand=psCommand & " -WindowStyle hidden"
    end if
    psCommand=psCommand & " -Command """ & psScript & """"
    psfiledialog=wShell.Exec(psCommand).StdOut.ReadLine()
end function
