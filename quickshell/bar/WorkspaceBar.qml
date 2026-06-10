// WorkspaceBar.qml
// Hyprland-only workspace pill row — Quickshell ≥ 0.2.1
// Requires Hyprland ≥ 0.55 (Lua config). hyprlang is not supported.
//
// Shows only ACTIVE workspaces — focused, or containing ≥1 window.
// Hyprland itself only ever creates a HyprlandWorkspace object for a
// workspace meeting that definition, so Hyprland.workspaces.values already
// IS the active set. The only filtering needed is restricting to numbered
// workspaces 1–9, which excludes special/scratchpad workspaces (negative ids).
//
// workspace.activate() is intentionally avoided — documented as equivalent
// to the old hyprlang dispatch string; fails silently under Lua config.
// All dispatch calls use the Lua dispatcher API directly.

import QtQuick
import Quickshell.Hyprland
import "../theme"

Row {
    id: root

    spacing: 4

    // ── Dispatch ──────────────────────────────────────────────────────────────
    // hl.dsp.focus is the Hyprland ≥ 0.55 Lua dispatcher for switching to a
    // workspace by id.
    function workspaceDispatch(wsId) {
        return 'hl.dsp.focus({ workspace = "' + wsId + '" })'
    }

    // ── Active workspaces (ids 1–9) ───────────────────────────────────────────
    // Hyprland.workspaces.values is sorted ascending by id, with special
    // workspaces (negative ids) first. Filtering to [1,9] excludes those and
    // preserves left-to-right numeric order with no extra sort step.
    //
    // This binding re-evaluates whenever Hyprland.workspaces changes — i.e.
    // whenever a workspace becomes active or stops being active (last window
    // closed and it loses focus). Pills appear and disappear automatically.
    readonly property var activeWorkspaces: {
        var list = Hyprland.workspaces.values
        var result = []
        for (var i = 0; i < list.length; i++) {
            if (list[i].id >= 1 && list[i].id <= 9)
                result.push(list[i])
        }
        return result
    }

    // ── Hover colours — computed once, shared by all pills ────────────────────
    readonly property color hoverActive:   Qt.lighter(PanelColors.workspaceActive,   1.15)
    readonly property color hoverInactive: Qt.lighter(PanelColors.workspaceInactive, 1.40)

    // ── Pills ─────────────────────────────────────────────────────────────────
    // model is an array of HyprlandWorkspace objects, so each delegate
    // receives its workspace directly as modelData — no id-based lookup.
    Repeater {
        model: root.activeWorkspaces

        delegate: Rectangle {
            id: pill

            required property var modelData

            width:  28
            height: 28
            radius: 5

            // HyprlandWorkspace.focused is reactive: Quickshell updates it on
            // every workspace object when focus changes, so this binding
            // tracks focus moves with no external singleton reference needed.
            color: {
                if (modelData.focused)
                    return pillArea.containsMouse ? root.hoverActive : PanelColors.workspaceActive
                return pillArea.containsMouse ? root.hoverInactive : PanelColors.workspaceInactive
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text:           modelData.id
                color:          modelData.focused ? PanelColors.pillForeground : PanelColors.textDim
                font.pixelSize: Fonts.panelFontSize
                font.bold:      Fonts.boldFont
                font.family:    Fonts.selectedFont

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                id:           pillArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: Hyprland.dispatch(root.workspaceDispatch(modelData.id))

                onWheel: event => {
                    event.accepted = true

                    var list = root.activeWorkspaces
                    if (list.length === 0)
                        return

                    var idx = list.findIndex(ws => ws.focused)
                    if (idx === -1)
                        idx = 0

                    var dir  = event.angleDelta.y < 0 ? 1 : -1
                    var next = ((idx + dir) % list.length + list.length) % list.length

                    Hyprland.dispatch(root.workspaceDispatch(list[next].id))
                }
            }
        }
    }
}
