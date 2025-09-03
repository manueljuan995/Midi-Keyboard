import QtQuick

Window {
    width: 1280
    height: 220
    visible: true
    title: qsTr("WaveForm")

    property var noteFrequency: {
        "C": 32.70319566257482,
        "C#": 34.64782887210901,
        "D": 36.70809598967594,
        "D#": 38.89087296526011,
        "E": 41.20344461410874,
        "F": 43.65352892912548,
        "F#": 46.24930283895429,
        "G": 48.99942949771866,
        "G#": 51.91308719749314,
        "A": 55.0,
        "A#": 58.27047018976123,
        "B": 61.73541265701551,
    };

    function getFq(octave, note) {
        return noteFrequency[note] * 2 ** (octave - 1);
    }

    function noteToString(octave, note) {
        return '%1%2'.arg(note).arg(octave);
    }

    function stringToNote(value) {
        var octave = value.slice(-1);
        var note = value.replace(octave, '');
        return [Number(octave), note]; 
    }

    Rectangle {
        anchors.fill: parent
        color: "#ECF0F1"

        WaveformView {
            id: waveformView

            anchors {
                left: parent.left; right: parent.right
                top: parent.top; bottom: keyboardView.top
            }
        }

        KeyboardView {
            id: keyboardView

            anchors {
                left: parent.left; right: parent.right
                bottom: parent.bottom
            }
            height: 110
        }
    }
}
