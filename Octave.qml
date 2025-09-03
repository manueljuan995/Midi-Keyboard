import QtQuick

Item {
    id: octaveView
    width: whiteKeyWidth * 2 + (blackKeyWidth - 10) * 5 + (whiteKeyWidth - 10) * 5 - 1 * 11
    height: whiteKeyHeight

    property int octave: 1
    property var notes: ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']

    property int whiteKeyWidth: 40
    property int whiteKeyHeight: 100
    property int blackKeyWidth: 20
    property int blackKeyHeight: 50

    Loader {
        id: key0
        property string note: "C"

        sourceComponent: keyWhiteComp
    }

    Loader {
        id: key1
        property string note: "C#"

        anchors {
            left: key0.right; leftMargin: -11
        }
        z: 1

        sourceComponent: keyBlackComp
    }

    Loader {
        id: key2
        property string note: "D"

        anchors {
            left: key1.right; leftMargin: -11
        }
        sourceComponent: keyWhiteOffsetComp
    }

    Loader {
        id: key3
        property string note: "D#"

        anchors {
            left: key2.right; leftMargin: -11
        }
        z: 1

        sourceComponent: keyBlackComp
    }

    Loader {
        id: key4
        property string note: "E"

        anchors {
            left: key3.right; leftMargin: -11
        }

        sourceComponent: keyWhiteOffsetComp
    }

    Loader {
        id: key5
        property string note: "F"

        anchors {
            left: key4.right; leftMargin: -1
        }
        sourceComponent: keyWhiteComp
    }

    Loader {
        id: key6
        property string note: "F#"

        anchors {
            left: key5.right; leftMargin: -11
        }
        z: 1

        sourceComponent: keyBlackComp
    }

    Loader {
        id: key7
        property string note: "G"

        anchors {
            left: key6.right; leftMargin: -11
        }
        sourceComponent: keyWhiteOffsetComp
    }

    Loader {
        id: key8
        property string note: "G#"

        anchors {
            left: key7.right; leftMargin: -11
        }
        z: 1

        sourceComponent: keyBlackComp
    }

    Loader {
        id: key9
        property string note: "A"

        anchors {
            left: key8.right; leftMargin: -11
        }
        sourceComponent: keyWhiteOffsetComp
    }

    Loader {
        id: key10
        property string note: "A#"

        anchors {
            left: key9.right; leftMargin: -11
        }
        z: 1

        sourceComponent: keyBlackComp
    }

    Loader {
        id: key11
        property string note: "B"

        anchors {
            left: key10.right; leftMargin: -11
        }
        sourceComponent: keyWhiteOffsetComp
    }

    Component {
        id: keyWhiteComp

        MouseArea {
            id: recKeyWhite
            width: 40
            height: 100

            onPressed: {
                midiHandler.noteon(noteToString(octave, note))
            }

            onReleased: {
                midiHandler.noteoff(noteToString(octave, note))
            }

            Gradient {
                id: pressedGradient
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: "#ecf0f1" }
             }

            Rectangle {
                anchors.fill: parent
                color: "white"
                border { color: "black"; width: 1 }
                gradient: recKeyWhite.pressed ? pressedGradient : undefined
            }
        }
    }

    Component {
        id: keyBlackComp

        MouseArea {
            id: recKeyBlack
            width: 20
            height: 50

            onPressed: {
                midiHandler.noteon(noteToString(octave, note))
            }

            onReleased: {
                midiHandler.noteoff(noteToString(octave, note))
            }

            Gradient {
                id: pressedGradient
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#444" }
                GradientStop { position: 1.0; color: "#222" }
             }

            Rectangle {
                anchors.fill: parent
                color: "black"
                gradient: recKeyBlack.pressed ? pressedGradient : undefined
            }
        }
    }

    Component {
        id: keyWhiteOffsetComp

        MouseArea {
            id: recKeyWhiteOffset
            width: 40
            height: 100

            onPressed: {
                console.log(noteToString(octave, note))
                midiHandler.noteon(noteToString(octave, note))
            }

            onReleased: {
                midiHandler.noteoff(noteToString(octave, note))
            }

            Gradient {
                id: pressedGradient
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: "#ecf0f1" }
             }

            Rectangle {
                anchors.fill: parent
                color: "white"
                border { color: "black"; width: 1 }
                gradient: recKeyWhiteOffset.pressed ? pressedGradient : undefined
            }
        }
    }
}
