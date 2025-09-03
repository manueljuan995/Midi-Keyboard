import QtQuick

Rectangle {
    id: waveformView

    Connections {
        target: midiHandler
        onFrequencyDataReady: (data) => {
            waveformCanvas.frequencyData = data;
        }
    }

    Canvas {
        id: waveformCanvas
        anchors.fill: parent
        property var ctx
        onAvailableChanged: if (available) ctx = getContext('2d');
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative

        property var grid: []
        property var frequencyData: []
        property int sampleRate: 48000
        property int bufferLength: 2048
        property real freqPerItem: (sampleRate / 2) / bufferLength

        onWidthChanged: {
            const _grid = [];
            if (width > 0) {
                let prevColumn = 0;
                for (let i = 0; i < bufferLength; i++) {
                    const column = midiHandler.scaleLog(Math.round((i + 1) * freqPerItem), width);
                    _grid.push([prevColumn, column - prevColumn]);

                    prevColumn = column;
                }
            }
            grid = _grid;
        }

        function draw() {
            if (!!ctx && frequencyData.length && grid.length) {
                ctx.clearRect(0, 0, width, height);

                if (frequencyData.length === 0) return;
                if (grid.length === 0) return;

                const gradient = ctx.createLinearGradient(0, height, 0, 0);
                gradient.addColorStop(0, '#2ecc71');
                gradient.addColorStop(1, '#3498db');

                for (let i = 0; i < bufferLength; i++) {
                    ctx.fillStyle = gradient;
                    ctx.fillRect(grid[i][0], height, grid[i][1], (-frequencyData[i] / 255) * height);
                }
            }

            requestAnimationFrame(draw);
        }
        
        onPaint: {
        }

        Component.onCompleted: {
            draw()
        }
    }
}
