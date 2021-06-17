import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui
import QtQuick.Controls.Material.impl 2.12

Rectangle
{
    id: control

    implicitHeight: Maui.Style.rowHeight
    //    implicitWidth: 500
    readonly property color m_color : Qt.tint(root.Kirigami.Theme.textColor, Qt.rgba(root.Kirigami.Theme.backgroundColor.r, root.Kirigami.Theme.backgroundColor.g, root.Kirigami.Theme.backgroundColor.b, 0.6))

    radius: Maui.Style.radiusV
    color : enabled ? Qt.rgba(m_color.r, m_color.g, m_color.b, 0.3) : "transparent"
    border.color: enabled ? "transparent" : Qt.rgba(m_color.r, m_color.g, m_color.b, 0.3)
    enabled: _projectManager.process.enabled
    ProgressBar
    {
        id: _progressBar
        anchors.fill: parent
        indeterminate: true
        visible: _projectManager.process.configureRunning || _projectManager.process.buildRunning
        contentItem: ProgressBarImpl {
            implicitHeight: 4

            scale: 1
            color: "violet"
            opacity: 0.3
            progress: _progressBar.position
            indeterminate: _progressBar.visible && _progressBar.indeterminate
        }


        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 4
            y: (_progressBar.height - height) / 2
            height: 4
            color: "transparent"
        }
    }

    RowLayout
    {
        anchors.fill: parent

        ToolButton
        {
            icon.name: "run-build"
            enabled: !_projectManager.process.processRunning
            onClicked:
            {
                _projectManager.process.build()
            }
        }

        Maui.ListItemTemplate
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            label1.text:  _projectManager.projectTitle
            label1.horizontalAlignment: Qt.AlignHCenter
            label2.horizontalAlignment: Qt.AlignHCenter
            label2.font.pointSize: Maui.Style.fontSizes.small
            label2.text: _projectManager.process.processRunning ? _projectManager.process.infoLabel :  _projectManager.projectPath
            imageSource: _projectManager.projectLogo
            imageSizeHint: Maui.Style.iconSizes.medium
            iconVisible: root.isWide
        }

        ToolButton
        {
            enabled: !_projectManager.process.buildRunning
            icon.name: _projectManager.process.binaryRunning ? "media-playback-stop" : "media-playback-start"
            onClicked:
            {
                if( _projectManager.process.binaryRunning)
                {
                    _projectManager.process.stopRun()
                }else
                {
                    _projectManager.process.run()
                }
            }
        }
    }
}
