import QtQuick

Item {
    id: keyboardView

    property var octaves: [1, 5]
    property int octavesCount: Math.min(octaves[1], Math.floor(width / 269)) - octaves[0] + 1

    Row {
        id: rowOctaves
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: -1

        Repeater {
            id: rptOctaves
            model: octavesCount

            delegate: Octave {
                octave: 1 + index
            }
        }
    }
}
