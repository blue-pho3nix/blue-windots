; ==================================================================
; AutoHotkey v2 Configuration for Komorebi
; ==================================================================

; Use AutoHotkey v2.0
#Requires AutoHotkey v2.0
; Ensure only one instance of the script is running
#SingleInstance Force

; ==================================================================
; Helper Function
; ==================================================================

; Function to send commands to komorebic.exe
Komorebic(cmd) {
  RunWait(Format("komorebic.exe {}", cmd), , "Hide")
}

; ==================================================================
; Hotkeys
; ==================================================================

; Focus windows
#Left::Komorebic("focus left")   ; win + left
#Right::Komorebic("focus right") ; wint + right
#Up::Komorebic("focus up")       ; win + up
#Down::Komorebic("focus down")   ; win + down 

; Resize windows
#=::Komorebic("resize-axis horizontal increase")  ; win + =
#-::Komorebic("resize-axis horizontal decrease")  ; win + - 
#+=::Komorebic("resize-axis vertical increase")   ; win + shift + =
#+-::Komorebic("resize-axis vertical decrease")   ; win + shift + -

; Promote windows: win + space
#Space::Komorebic("promote")  

; Focus on Workspace
#1::Komorebic("focus-workspace 0")  ; win + 1 (focus on workspace 1)
#2::Komorebic("focus-workspace 1")  ; win + 2 (focus on workspace 2)
#3::Komorebic("focus-workspace 2")  ; win + 3 (focus on workspace 3)
#4::Komorebic("focus-workspace 3")  ; win + 4 (focus on workspace 4)

; Move windows to Workspaces
+#1::Komorebic("move-to-workspace 0")  ; shift + win + 1 (move window to workspace 1)
+#2::Komorebic("move-to-workspace 1")  ; shift + win + 2 (move window to workspace 2)
+#3::Komorebic("move-to-workspace 2")  ; shift + win + 3 (move window to workspace 3)
+#4::Komorebic("move-to-workspace 3")  ; shift + win + 4 (move window to workspace 4)

; Move windows to left or right... includes monitors
+#Left::Komorebic("move left")    ; shift + win + left 
+#Right::Komorebic("move right")  ; shift + win + right

; ==================================================================
; Custom App/Link Hotkeys
; ==================================================================

; Open Default Browser: win + w
#w::Run("https://www.google.com") 

; Open Powershell ; win + enter
#Enter::Run("wt.exe")  

; Open Powershell as Administrator: shift + win + enter
+#Enter:: {
app := 'wt.exe'
commandLine := '"' app '"'
Run '*RunAs ' commandLine

}

; Open Command Prompt: win + c
#c::Run("wt.exe -p `"Command Prompt`"") 

; Open Command Prompt as Administrator: shift + win + c
+#c:: {
app := 'wt.exe -p `"Command Prompt`"'
Run '*RunAs ' app
}

; Open File Explorer: win + f
#f::Run("explorer.exe")

; Close the focused window:  win + q
#q:: {
    hwnd := WinExist("A")
    if hwnd
        WinClose(hwnd)
}


