import qs
import QtQuick

Pill {
    id: root

    visible: BatterySource.available

    Item {
        implicitWidth: row.implicitWidth + Theme.innerPadH * 2
        implicitHeight: Theme.barHeight - 10

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontMd
                color: {
                    if (BatterySource.charging)
                        return Theme.green;
                    const p = BatterySource.percentage;
                    if (p < 15)
                        return Theme.red;
                    if (p < 30)
                        return Theme.peach;
                    if (p < 50)
                        return Theme.yellow;
                    return Theme.teal;
                }

                text: {
                    if (BatterySource.charging)
                        return "󱐋";
                    const p = BatterySource.percentage;
                    if (p < 10)
                        return "󰁺";
                    if (p < 20)
                        return "󰁻";
                    if (p < 30)
                        return "󰁼";
                    if (p < 40)
                        return "󰁽";
                    if (p < 50)
                        return "󰁾";
                    if (p < 60)
                        return "󰁿";
                    if (p < 70)
                        return "󰂀";
                    if (p < 80)
                        return "󰂁";
                    if (p < 90)
                        return "󰂂";
                    return "󰁹";
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: Theme.fontSm
                color: Theme.text
                text: Math.round(BatterySource.percentage) + "%"
            }
        }
    }
}
