#Requires AutoHotkey v2.0
#SingleInstance force

SetWorkingDir(EnvGet("UserProfile"))

GroupAdd("neovim", "ahk_exe neovide.exe ahk_class Window Class")
GroupAdd("terminal", "ahk_exe wezterm-gui.exe")

; Get window position without the invisible border.
WinGetPosEx(&X, &Y, &W, &H, hwnd) {
    static DWMWA_EXTENDED_FRAME_BOUNDS := 9
    DllCall("dwmapi\DwmGetWindowAttribute"
            , "ptr" , hwnd
            , "uint", DWMWA_EXTENDED_FRAME_BOUNDS
            , "ptr" , RECT := Buffer(16, 0)
            , "uint", RECT.size
            , "uint")
    X := NumGet(RECT, 0, "int")
    Y := NumGet(RECT, 4, "int")
    W := NumGet(RECT, 8, "int") - X
    H := NumGet(RECT, 12, "int") - Y
}

; Move window and fix offset from invisible border.
WinMoveEx(X, Y, W, H, hwnd) {
    WinGetPosEx(&fX, &fY, &fW, &fH, hwnd)
    WinGetPos(&wX, &wY, &wW, &wH, hwnd)
    xDiff := fX - wX
    hDiff := wH - fH
    nX := X - xDiff
    nY := Y
    nW := W + xDiff * 2
    nH := H + hDiff
    WinMove(nX, nY, nW, nH, hwnd)
}

Join(strArray)
{
  s := ""
  for i,v in strArray
    s .= ", " . v
  return SubStr(s, 3)
}

GetActiveWindow()
{
    return WinExist("A")
}

GetParentWindow(window)
{
    return DllCall("GetParent", "ptr", window)
}

GetWindowsAtPosition(x, y)
{
    windows := Array()

    for window in WinGetList()
    {
        title := WinGetTitle(window)
        if title == "Program Manager" or title == "NVIDIA GeForce Overlay"
            continue

        try {
            process := WinGetProcessName(window)
        } catch {
            continue
        }

        if process == "explorer.exe"
            continue

        WinGetPosEx(&winX, &winY, &winWidth, &winHeight, window)

        if x < winX || x > (winX + winWidth) || y < winY || y > (winY + winHeight)
            continue

        windows.Push(window)
    }

    return windows
}

GetWindowUnder(hwnd)
{
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, hwnd)
    windows := GetWindowsAtPosition(winX + winWidth / 2, winY + winHeight / 2)
    return_next := false

    for window in windows
    {
        if return_next
            return window
        if window == hwnd
            return_next := true
    }
}

MakeWindowSameSizeAs(windowToResize, otherWindow)
{
    if !windowToResize || !otherWindow
        return
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, otherWindow)
    WinMoveEx(winX, winY, winWidth, winHeight, windowToResize)
}

GrowWindow(hwnd, pixels)
{
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, hwnd)
    WinMoveEx(winX - pixels, winY - pixels, winWidth + pixels * 2, winHeight + pixels * 2, hwnd)
}

ActivateOrCycle(xOffsetRatio, yOffsetRatio)
{
    xOffset := A_ScreenWidth * xOffsetRatio
    yOffset := A_ScreenHeight * yOffsetRatio
    windows := GetWindowsAtPosition(xOffset, yOffset)

    for window in windows
    {
        if !WinActive(window)
        {
            WinActivate(window)
            break
        }
    }
}

focusMap := Map()
Focus(xOffsetRatio, yOffsetRatio, name)
{
    if focusMap.Has(name)
    {
        Unfocus(name)
        return
    }

    ; Get windows in the zone to focus
    xOffset := A_ScreenWidth * xOffsetRatio
    yOffset := A_ScreenHeight * yOffsetRatio
    windows := GetWindowsAtPosition(xOffset, yOffset)
    if windows.Length == 0
        return

    ; Get windows in the central zone
    centralWindows := GetWindowsAtPosition(A_ScreenWidth / 2, A_ScreenHeight / 2)
    if centralWindows.Length == 0
        return

    WinActivate(windows[1])

    ; Store original position of window to focus
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, windows[1])
    focusMap[name] := [windows[1], winX, winY, winWidth, winHeight]

    ; Move window to focus to central zone
    WinGetPosEx(&centralWinX, &centralWinY, &centralWinWidth, &centralWinHeight, centralWindows[1])
    WinMoveEx(centralWinX, centralWinY, centralWinWidth, centralWinHeight, windows[1])
}

FocusActive()
{
    focusMap.Delete("active")
    hwnd := GetActiveWindow()
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, hwnd)
    Focus((winX + winWidth / 2) / A_ScreenWidth, (winY + winHeight / 2) / A_ScreenHeight, "active")
}

Unfocus(name)
{
    if focusMap.Has(name)
    {
        pos := focusMap.Get(name)
        focusMap.Delete(name)
        if WinExist(pos[1])
        {
            WinMoveEx(pos[2], pos[3], pos[4], pos[5], pos[1])
            return
        }
    }
}

UnfocusAll()
{
    map := focusMap.Clone()
    for name in map
        Unfocus(name)
}

NextWindowInZone()
{
    WinGetPosEx(&winX, &winY, &winWidth, &winHeight, GetActiveWindow())
    NextWindowAtPosition(winX + winWidth / 2, winY + winHeight / 2)
}

PreviousWindowInZone()
{
    WinGetPos(&winX, &winY, &winWidth, &winHeight, GetActiveWindow())
    PreviousWindowAtPosition(winX + winWidth / 2, winY + winHeight / 2)
}

NextWindowAtPosition(x ,y)
{
    windows := GetWindowsAtPosition(x, y)
    if windows.Length <= 1
        return
    WinMoveBottom(windows[1])
    WinActivate(windows[2])
}

PreviousWindowAtPosition(x ,y)
{
    windows := GetWindowsAtPosition(x, y)

    if windows.Length > 1
    {
        WinMoveTop(windows[windows.Length])
        WinActivate(windows[windows.Length])
    }
}

RunAndActivate(command)
{
    Run(command,,,&pid)
    WinWait("ahk_pid " pid)
    WinActivate("ahk_pid " pid)
}

RunWindowsTerminal()
{
    WinActivate("Program Manager")
    Run(EnvGet("LocalAppData") "/Microsoft/WindowsApps/wt.exe")
}

; Remap caps lock to CTRL.
$CapsLock::Ctrl

; The desktop is divided into these zones:
;
; q w e
; a w d
;
; Win + zone activates the topmost application in the zone if the current active window is not in that zone.
; If the current active window is already in the zone, Win + zone will activate the window underneath the
; current active window.
#q::ActivateOrCycle(0.1, 0.1)
#w::ActivateOrCycle(0.5, 0.1)
#e::ActivateOrCycle(0.9, 0.1)
#a::ActivateOrCycle(0.1, 0.9)
#d::ActivateOrCycle(0.9, 0.9)

; Shift + Win + zone focuses the window in that zone to the central zone if it's not already there.
; If it has been previously focused, return it to its previous location.
+#q::Focus(0.1, 0.1, "q")
+#e::Focus(0.9, 0.1, "e")
+#a::Focus(0.1, 0.9, "a")
+#d::Focus(0.9, 0.9, "d")

; Shift + Win + w focuses the current active window.
+#w::FocusActive()
; Win + s unfocuses all previously focused windows.
#s::UnfocusAll()

; Shift + Win + +/- will grow or shrink the current active window
+#-::GrowWindow(GetActiveWindow(), -20)
+#+::GrowWindow(GetActiveWindow(), 20)

; Shift + Win + p will make the current active window the same size as the window underneath it.
+#p::MakeWindowSameSizeAs(GetActiveWindow(), GetWindowUnder(GetActiveWindow()))

; CTRL + Win + h/j/k/l will simulate cursor keys
^#h::Left
^#j::Down
^#k::Up
^#l::Right

; Application shortcuts:
;
; n - neovide
; x - wezterm
;
; Win + application will activate the next instance of the application.
; Shift + Win + application will run a new instance of the application.
#n::GroupActivate("neovim", "R")
+#n::RunAndActivate(EnvGet("UserProfile") "/.cargo/bin/neovide.exe")
#x::GroupActivate("terminal", "R")
+#x::RunAndActivate(EnvGet("UserProfile") "/scoop/apps/wezterm-nightly/current/wezterm-gui.exe")

; Win + j/k will activate the next/previous application in the current zone.
#j::NextWindowInZone()
#k::PreviousWindowInZone()

; Shift + Win + h/l maps to Ctrl+PgUp/Ctrl+PgDn which normally switches tabs.
+#h::^PgUp
+#l::^PgDn

; Win + Esc exits the current application.
#Esc::!F4
; Win + F11 edits this AHK file.
#F11::Edit()
; Win + F12 reloads this AHK file.
#F12::Reload()

#HotIf WinActive("ahk_exe Slack.exe")
^PgUp::!Up
^PgDn::!Down
+^PgUp::+^Tab
+^PgDn::^Tab
#HotIf

#HotIf WinActive("Discord |")
^PgUp::!Up
^PgDn::!Down
+^PgUp::^!Up
+^PgDn::^!Down
#HotIf

:*:egrim::😬
:*:ehearts::❤️❤️❤️
:*:ehearteyes::😍😍😍
:*:eheartface::🥰🥰🥰
:*:esmile::😊
:*:ejoy::😂
:*:ecry::😢
:*:eloudcry::😭
:*:etear::🥲
:*:evomit::🤮
:*:ewink::😉
