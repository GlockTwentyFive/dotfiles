// WorkspaceBar.qml
// Hyprland-only workspace pill row — Quickshell ≥ 0.2.1
// Requires Hyprland ≥ 0.55 (Lua config). hyprlang is not supported.
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
    function workspaceDispatch(wsNum) {
        return 'hl.dsp.focus({ workspace = "' + wsNum + '" })'
    }

    // ── Workspace map — O(1) per-pill lookup ──────────────────────────────────
    // Rebuilt when Hyprland.workspaces changes (workspace created/destroyed).
    // Maps id → HyprlandWorkspace. Named/special workspaces have negative ids;
    // harmlessly included since pills only query ids 1–9.
    readonly property var workspaceMap: {
        var map = {}
        var list = Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++)
            map[list[i].id] = list[i]
        return map
    }

    // ── Dynamic pill count ────────────────────────────────────────────────────
    // displayCount = min( max(maxOccupied, focusedId) + 1 , 9 )
    //
    // maxOccupied  — highest workspace id [1,9] that has ≥1 open window.
    //                Floor of 1 so the bar is never empty.
    // focusedId    — Hyprland.focusedWorkspace.id, clamped to [1,9].
    //                Using 0 when out-of-range so max() always prefers
    //                maxOccupied in those cases (special/named workspaces).
    //
    // WHY include focusedId:
    //   Without it, pressing Super+7 on an otherwise empty workspace would
    //   never extend the bar beyond maxOccupied, leaving workspace 7 invisible
    //   and unhighlighted — exactly the bug seen in the screenshots.
    //
    // WHY reactive binding instead of Connections + Component.onCompleted:
    //   Connections have an initialisation timing hazard: if Hyprland hasn't
    //   finished populating workspaces/toplevels when onCompleted fires, the
    //   first call produces a stale count. A reactive binding has no such
    //   hazard — it re-evaluates automatically and correctly whenever any of
    //   its dependencies (workspaces, toplevels, focusedWorkspace) change.
    //
    // Trailing slot behaviour:
    //   There is always exactly one trailing empty pill beyond the last
    //   meaningful workspace (max of occupied and focused). Navigating to the
    //   trailing slot advances focusedId, which extends displayCount by 1 and
    //   creates a new trailing slot — identical to GNOME's dynamic workspaces.
    //   When you leave the empty slot Hyprland destroys it; the reactive
    //   binding immediately collapses displayCount back. You never see more
    //   than one extra empty pill at a time.
    readonly property int displayCount: {
        var maxOccupied = 1
        var list = Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++) {
            var ws = list[i]
            if (ws.id >= 1 && ws.id <= 9 &&
                    ws.toplevels.values.length > 0 && ws.id > maxOccupied)
                maxOccupied = ws.id
        }

        // Standard count: highest occupied workspace + 1 trailing slot.
        var standardCount = Math.min(maxOccupied + 1, 9)

        // Only extend beyond the standard trailing slot when the user has
        // jumped PAST it via a direct keybinding (e.g. Super+7 when trailing
        // is at workspace 4). In that case show the focused workspace plus a
        // new trailing slot.
        //
        // Critically: if focusedId == standardCount (focused IS the trailing
        // slot, reached via scroll or click), we do NOT extend. This prevents
        // the cascade where focusing the trailing slot immediately creates
        // another one, which would cause scroll wrap-around to never fire.
        var fw = Hyprland.focusedWorkspace
        var focusedId = (fw !== null && fw.id >= 1 && fw.id <= 9) ? fw.id : 0
        if (focusedId > standardCount)
            return Math.min(focusedId + 1, 9)

        return standardCount
    }

    // ── Hover colours — computed once, shared by all pills ────────────────────
    readonly property color hoverActive:   Qt.lighter(PanelColors.workspaceActive,   1.15)
    readonly property color hoverInactive: Qt.lighter(PanelColors.workspaceInactive, 1.40)

    // ── Workspace pills ───────────────────────────────────────────────────────
    Repeater {
        model: root.displayCount

        delegate: Rectangle {
            id: pill

            required property int modelData

            // Workspace number (1–N where N = displayCount)
            readonly property int wsNum: modelData + 1

            // O(1) lookup from root-level map. Null for workspaces that don't
            // exist yet in the compositor (empty non-focused slots).
            // ?? converts undefined (missing key) to null for a clean contract.
            readonly property var workspace: root.workspaceMap[wsNum] ?? null

            // True when this is the focused monitor's active workspace.
            readonly property bool isFocused:
                Hyprland.focusedWorkspace !== null &&
                Hyprland.focusedWorkspace.id === wsNum

            // True when ≥1 toplevel lives on this workspace.
            // Drives opacity — workspaceInactive was only ever painted on
            // occupied workspaces in the original; empty pills are dimmed.
            readonly property bool hasClients:
                workspace !== null &&
                workspace.toplevels.values.length > 0

            width:  28
            height: 28
            radius: 5

            // Full opacity when focused or occupied (matches original intent:
            // workspaceActive/Inactive were never rendered at reduced opacity).
            // Empty non-focused pills dim to 70% — communicates "available
            // but unused" without a third theme colour.
            opacity: (isFocused || hasClients) ? 1.0 : 0.7

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // containsMouse is already reactive when hoverEnabled is set.
            // No auxiliary hovered property needed.
            color: {
                if (isFocused)
                    return pillArea.containsMouse
                           ? root.hoverActive
                           : PanelColors.workspaceActive
                return pillArea.containsMouse
                       ? root.hoverInactive
                       : PanelColors.workspaceInactive
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text:           pill.wsNum
                color:          pill.isFocused ? PanelColors.pillForeground : PanelColors.textDim
                font.pixelSize: Fonts.panelFontSize
                font.bold:      Fonts.boldFont
                font.family:    Fonts.selectedFont

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }

            MouseArea {
                id:              pillArea
                anchors.fill:    parent
                hoverEnabled:    true
                acceptedButtons: Qt.LeftButton

                onClicked: Hyprland.dispatch(root.workspaceDispatch(pill.wsNum))

                onWheel: event => {
                    // Consume event — prevent propagation to parent containers.
                    event.accepted = true

                    var focused = Hyprland.focusedWorkspace
                    if (focused === null)
                        return

                    // Wrap-around using modular arithmetic.
                    // +count before % prevents negative remainder on backward
                    // wrap (JS % is remainder, not true modulo).
                    //
                    // count=5 examples:
                    //   focused=5 → forward  → ((4+1+5)%5)+1 = 0+1 = 1  ✓
                    //   focused=1 → backward → ((0-1+5)%5)+1 = 4+1 = 5  ✓
                    var dir   = event.angleDelta.y < 0 ? 1 : -1
                    var count = root.displayCount
                    var next  = ((focused.id - 1 + dir + count) % count) + 1

                    Hyprland.dispatch(root.workspaceDispatch(next))
                }
            }
        }
    }
}
