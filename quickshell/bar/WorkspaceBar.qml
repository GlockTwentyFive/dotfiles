// WorkspaceBar.qml
// Hyprland-only workspace pill row — Quickshell ≥ 0.2.1
// Requires Hyprland ≥ 0.55 (Lua config). hyprlang is not supported.
//
// workspace.activate() is intentionally avoided — it is documented as
// equivalent to the old hyprlang dispatch string ("workspace <name>") and
// fails silently under Lua config. All dispatch calls use the Lua
// dispatcher API directly via Hyprland.dispatch().
//
// Trailing workspace logic:
//   displayCount = maxOccupiedWorkspace + 1
//   "Occupied" means the workspace has ≥1 open window. A focused-but-empty
//   workspace does NOT advance maxOccupiedWorkspace and therefore does NOT
//   create a new trailing slot. Exactly one trailing empty pill exists at all
//   times. A new trailing slot only appears when a window is opened on the
//   previously trailing workspace, promoting it to occupied and extending the
//   bar by one.

import QtQuick
import Quickshell.Hyprland
import "../theme"

Row {
    id: root

    spacing: 4

    // ── Dispatch helper ───────────────────────────────────────────────────────
    // Generates the Lua dispatcher string for focusing a workspace by number.
    // hl.dsp.focus is the Hyprland ≥ 0.55 equivalent of the old hyprlang
    // "workspace N" dispatcher.
    function workspaceDispatch(wsNum) {
        return 'hl.dsp.focus({ workspace = "' + wsNum + '" })'
    }

    // ── Workspace map — O(1) per-pill lookup ──────────────────────────────────
    // Rebuilt whenever Hyprland.workspaces changes. Maps workspace id → object.
    // Pills resolve their HyprlandWorkspace in O(1) instead of scanning the
    // full array. Named/special workspaces have negative ids and are harmlessly
    // included; pills only query ids 1–9.
    readonly property var workspaceMap: {
        var map = {}
        var list = Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++)
            map[list[i].id] = list[i]
        return map
    }

    // ── Dynamic pill count ────────────────────────────────────────────────────
    // Updated imperatively so the dependency surface is explicit:
    //   - Hyprland.workspaces: workspace objects created or destroyed
    //   - Hyprland.toplevels:  any window opened or closed anywhere
    //
    // maxOccupiedWorkspace is the highest id in [1,9] where
    // toplevels.values.length > 0. Focused-but-empty workspaces are
    // deliberately excluded — focusing the trailing slot must not push a
    // new empty slot ahead of it.
    //
    // Floor of 1: guarantees at least workspace 1 + trailing slot are shown
    // before Hyprland has populated any workspace state. Capped at 9.
    property int displayCount: 2

    function _updateDisplayCount() {
        var max  = 1
        var list = Hyprland.workspaces.values
        for (var i = 0; i < list.length; i++) {
            var ws = list[i]
            if (ws.id >= 1 && ws.id <= 9 &&
                    ws.toplevels.values.length > 0 && ws.id > max)
                max = ws.id
        }
        displayCount = Math.min(max + 1, 9)
    }

    // Seed the correct value as soon as the component is live. At this point
    // Hyprland.workspaces.values is already populated (assuming Quickshell
    // connects to Hyprland before QML creation completes), so the result is
    // meaningful rather than the default of 2.
    Component.onCompleted: _updateDisplayCount()

    // React to workspace objects being created or destroyed (e.g. Hyprland
    // removes an empty workspace when the user navigates away from it).
    Connections {
        target: Hyprland.workspaces
        function onObjectInsertedPost() { root._updateDisplayCount() }
        function onObjectRemovedPost()  { root._updateDisplayCount() }
    }

    // React to any window opening or closing. A window opening on the trailing
    // workspace is the sole event that promotes it to occupied and extends the
    // bar. A window closing on the highest occupied workspace may shrink the bar.
    Connections {
        target: Hyprland.toplevels
        function onObjectInsertedPost() { root._updateDisplayCount() }
        function onObjectRemovedPost()  { root._updateDisplayCount() }
    }

    // ── Hover colours — computed once, shared by all pills ────────────────────
    // Qt.lighter() is called once per theme change here at root, not on every
    // per-pill colour-binding evaluation.
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

            // O(1) lookup from root-level map. Returns null for the trailing
            // empty slot and any other workspace not yet in the compositor.
            // ?? converts undefined (missing map key) to null; workspace is
            // therefore always either null or a valid HyprlandWorkspace.
            readonly property var workspace: root.workspaceMap[wsNum] ?? null

            // True when this workspace is on the currently focused monitor.
            // Binds directly to the reactive Hyprland singleton property.
            // Null guard covers startup before focusedWorkspace is populated.
            readonly property bool isFocused:
                Hyprland.focusedWorkspace !== null &&
                Hyprland.focusedWorkspace.id === wsNum

            // True when ≥1 toplevel lives on this workspace.
            // In the original, workspaceInactive was only ever painted on
            // occupied workspaces — empty non-focused pills were hidden via
            // shouldShow. Since the trailing slot is always visible here,
            // hasClients drives opacity to give empty pills a visually
            // distinct, subdued appearance without adding a third theme colour.
            readonly property bool hasClients:
                workspace !== null &&
                workspace.toplevels.values.length > 0

            width:  28
            height: 28
            radius: 5

            // Full opacity when focused or occupied; dimmed when empty
            // (trailing slot). Mirrors the original's hide behaviour — empty
            // non-focused workspaces were invisible; here they are present but
            // clearly subordinate. Text and background dim together via
            // inheritance, which is the desired effect.
            opacity: (isFocused || hasClients) ? 1.0 : 0.4

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // containsMouse is reactive on MouseArea when hoverEnabled is set.
            // No auxiliary hovered property or entered/exited handlers needed.
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

            // ── Number label ──────────────────────────────────────────────────
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

            // ── Input ─────────────────────────────────────────────────────────
            MouseArea {
                id:              pillArea
                anchors.fill:    parent
                hoverEnabled:    true
                acceptedButtons: Qt.LeftButton

                onClicked: Hyprland.dispatch(root.workspaceDispatch(pill.wsNum))

                onWheel: event => {
                    // Explicitly consume the event to prevent propagation to
                    // any parent scrollable container.
                    event.accepted = true

                    var focused = Hyprland.focusedWorkspace
                    if (focused === null)
                        return

                    // Wrap-around scroll using modular arithmetic.
                    // dir: +1 = forward (scroll down), -1 = backward (scroll up).
                    // Adding count before % prevents negative remainder for the
                    // backward-from-first case (JS % is remainder, not modulo).
                    //
                    // Examples with displayCount = 5:
                    //   focused=5, forward  → ((5-1+1+5) % 5)+1 = 0+1 = 1  ✓
                    //   focused=1, backward → ((1-1-1+5) % 5)+1 = 4+1 = 5  ✓
                    var dir   = event.angleDelta.y < 0 ? 1 : -1
                    var count = root.displayCount
                    var next  = ((focused.id - 1 + dir + count) % count) + 1

                    Hyprland.dispatch(root.workspaceDispatch(next))
                }
            }
        }
    }
}
