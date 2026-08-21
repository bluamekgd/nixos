import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    property var workspaces: []
    property int activeWorkspace: -1

    property var windows: []
    property var activeWindow: null

    property string clockText: ""
    property string batteryText: "--"

    function updateClock() {
        const now = new Date()

        const hours = String(now.getHours()).padStart(2, "0")
        const minutes = String(now.getMinutes()).padStart(2, "0")

        const days = [
            "Sun",
            "Mon",
            "Tue",
            "Wed",
            "Thu",
            "Fri",
            "Sat"
        ]

        const day = days[now.getDay()]

        const date = String(now.getDate()).padStart(2, "0")
        const month = String(now.getMonth() + 1).padStart(2, "0")
        const year = String(now.getFullYear()).slice(-2)

        clockText = `${hours}:${minutes} (${day}) ${date}.${month}.${year}`
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: updateClock()
    }

    Component.onCompleted: {
        updateClock()
        batteryProcess.running = true
    }

    Process {
        id: batteryProcess

        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]

        stdout: SplitParser {
            onRead: data => {
                batteryText = data.trim() + "%"
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true

        onTriggered: {
            batteryProcess.running = false
            batteryProcess.running = true
        }
    }

    Process {
        id: niriEvents

        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const event = JSON.parse(data)

                // Workspaces
                if (event.WorkspacesChanged) {
                    workspaces = event.WorkspacesChanged.workspaces
                }

                if (event.WorkspaceActivated) {
                    activeWorkspace = event.WorkspaceActivated.id

                    workspaces = workspaces.map(ws => {
                        return Object.assign({}, ws, {
                            is_active: ws.id === activeWorkspace
                        })
                    })
                }

                // Initial window list
                if (event.WindowsChanged) {
                    windows = event.WindowsChanged.windows
                    activeWindow = windows.find(win => win.is_focused) || null
                }

                // Window opened or changed
                if (event.WindowOpenedOrChanged) {
                    const window = event.WindowOpenedOrChanged.window

                    windows = windows.filter(win => win.id !== window.id)
                    windows.push(window)

                    if (window.is_focused) {
                        activeWindow = window
                    }
                }

                // Window closed
                if (event.WindowClosed) {
                    const id = event.WindowClosed.id

                    windows = windows.filter(win => win.id !== id)

                    if (activeWindow && activeWindow.id === id) {
                        activeWindow = null
                    }
                }

                // Focus changed
                if (event.WindowFocusChanged) {
                    const id = event.WindowFocusChanged.id

                    activeWindow = windows.find(win => win.id === id) || null
                }
            }
        }
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 36

        color: "#1e1e2e"

        // Workspaces
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10

            spacing: 6

            Repeater {
                model: workspaces

                Rectangle {
                    required property var modelData

                    implicitWidth: 24
                    implicitHeight: 23

                    radius: 6

                    color: modelData.is_active
                           ? "#89b4fa"
                           : "#313244"

                    Text {
                        anchors.centerIn: parent

                        text: modelData.name
                              || modelData.idx.toString()

                        color: modelData.is_active
                               ? "#11111b"
                               : "#cdd6f4"

                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            niriFocus.running = false
                            niriFocus.command = [
                                "niri",
                                "msg",
                                "action",
                                "focus-workspace",
                                modelData.idx.toString()
                            ]
                            niriFocus.running = true
                        }
                    }
                }
            }
        }

        // Active window title
        Text {
            anchors.centerIn: parent

            text: activeWindow ? activeWindow.title : ""

            color: "#cdd6f4"

            font.pixelSize: 14

            width: parent.width * 0.4

            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        // Right-side information
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10

            spacing: 6

            // Battery
            Rectangle {
                implicitWidth: batteryLabel.implicitWidth + 16
                implicitHeight: 23

                radius: 6

                color: "#313244"

                Text {
                    id: batteryLabel

                    anchors.centerIn: parent

                    text: batteryText

                    color: "#cdd6f4"

                    font.pixelSize: 14
                }
            }

            // Clock
            Rectangle {
                implicitWidth: clockLabel.implicitWidth + 16
                implicitHeight: 23

                radius: 6

                color: "#313244"

                Text {
                    id: clockLabel

                    anchors.centerIn: parent

                    text: clockText

                    color: "#cdd6f4"

                    font.pixelSize: 14
                }
            }
        }
    }

    Process {
        id: niriFocus
    }
}

