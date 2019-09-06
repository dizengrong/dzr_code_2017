import QtQuick 2.4

Item {
    width: 400
    height: 400

    TextEdit {
        id: textEdit
        x: 43
        y: 41
        width: 80
        height: 20
        text: qsTr("Text Edit")
        font.pixelSize: 12
    }
}
