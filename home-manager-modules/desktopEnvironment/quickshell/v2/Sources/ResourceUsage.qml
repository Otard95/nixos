pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real memoryTotal: 1
    property real memoryAvailable: 0
    readonly property real memoryUsed: memoryTotal - memoryAvailable
    readonly property real memoryUsedPercentage: memoryUsed / memoryTotal
    property real cpuUsage: 0
    property var previousCpuStats: null

    function update() {
        meminfo.reload()
        stat.reload()

        const memory = meminfo.text()
        memoryTotal = Number(memory.match(/MemTotal:\s+(\d+)/)?.[1] ?? 1)
        memoryAvailable = Number(memory.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0)

        const cpu = stat.text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/m)
        if (!cpu) return

        const values = cpu.slice(1).map(Number)
        const total = values.reduce((sum, value) => sum + value, 0)
        const idle = values[3]
        if (previousCpuStats !== null) {
            const totalDelta = total - previousCpuStats.total
            const idleDelta = idle - previousCpuStats.idle
            cpuUsage = totalDelta > 0 ? 1 - idleDelta / totalDelta : 0
        }
        previousCpuStats = { total, idle }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
    }

    FileView {
        id: stat
        path: "/proc/stat"
    }
}
