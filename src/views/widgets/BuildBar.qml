import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Rectangle
{
    id: control

    implicitHeight: Maui.Style.rowHeight
//    implicitWidth: 500
    readonly property color m_color : Qt.tint(root.Kirigami.Theme.textColor, Qt.rgba(root.Kirigami.Theme.backgroundColor.r, root.Kirigami.Theme.backgroundColor.g, root.Kirigami.Theme.backgroundColor.b, 0.6))

    radius: Maui.Style.radiusV
    color : Qt.rgba(m_color.r, m_color.g, m_color.b, 0.3)

    ProgressBar
    {
        id: _progressBar
        anchors.fill: parent
        from : 0
        to : 1
//        value: _browserView.currentBrowser.loadProgress
//        visible: _browserView.currentBrowser.loading

        background: Rectangle {
                implicitWidth: 200
                implicitHeight: 6
                color: "transparent"
                radius: control.radius
            }

            contentItem: Item {
                implicitWidth: 200
                implicitHeight: 4

                Rectangle {
                    width: _progressBar.visualPosition * parent.width
                    height: parent.height
                    radius: control.radius
                    color: control.Kirigami.Theme.highlightColor
                    opacity: 0.3
                }
            }
    }

    RowLayout
    {
        anchors.fill: parent

        ToolButton
        {
            icon.name: "run-build"
        }

        Maui.ListItemTemplate
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            label1.text:  "Project Name"
            label1.horizontalAlignment: Qt.AlignHCenter
            label2.horizontalAlignment: Qt.AlignHCenter
            label2.font.pointSize: Maui.Style.fontSizes.small
            label2.text:  "Current project file URL"
            imageSource:  "vvave"
            imageSizeHint: Maui.Style.iconSizes.medium
        }

        ToolButton
        {
            icon.name: "media-playback-start"
        }
    }
}
