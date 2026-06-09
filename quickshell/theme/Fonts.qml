pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property string selectedFont: "Lexend"
    readonly property string selectedMonoFont: "JetBrainsMono Nerd Font"
    readonly property bool boldFont: false
    readonly property double panelFontSize: 14
    readonly property double panelIconSize: 14

    readonly property double popupsFontSize: 11  // unused

    readonly property double launcherFontSize: 14  // List view
    readonly property double clipboardFontSize: 13
}
