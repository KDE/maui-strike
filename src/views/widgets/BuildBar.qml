import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.2 as Maui

Item
{
    id: control

    implicitHeight: Maui.Style.rowHeight
    //    implicitWidth: 500
    //    readonly property color m_color : Qt.tint(root.Kirigami.Theme.textColor, Qt.rgba(root.Kirigami.Theme.backgroundColor.r, root.Kirigami.Theme.backgroundColor.g, root.Kirigami.Theme.backgroundColor.b, 0.6))


    //    radius: Maui.Style.radiusV
    //    color : enabled ? Qt.rgba(m_color.r, m_color.g, m_color.b, 0.3) : "transparent"
    //    border.color: enabled ? "transparent" : Qt.rgba(m_color.r, m_color.g, m_color.b, 0.3)

    enabled: _projectManager.process.enabled


    RowLayout
    {
        anchors.fill: parent
        spacing: 2

        MouseArea
        {
            id: _buildButton
            Layout.fillHeight: true
            Layout.preferredWidth: height * 1.5
            opacity: enabled ? 1 : 0.4
            hoverEnabled: true
            enabled: !_projectManager.process.processRunning
            onClicked:
            {
                _projectManager.process.build()
            }

            Kirigami.ShadowedRectangle
            {
                anchors.fill: parent
                color: Qt.lighter(Kirigami.Theme.backgroundColor)

                corners
                {
                    topLeftRadius: Maui.Style.radiusV
                    topRightRadius: 0
                    bottomLeftRadius: Maui.Style.radiusV
                    bottomRightRadius: 0
                }

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: "run-build"

                    color: _buildButton.containsMouse || _buildButton.containsPress ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                    width: Maui.Style.iconSizes.small
                    height: width
                }
            }
        }

        Rectangle
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.lighter(Kirigami.Theme.backgroundColor)

            Maui.ListItemTemplate
            {
                anchors.fill: parent
                label1.text:  _projectManager.projectTitle
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                label2.font.pointSize: Maui.Style.fontSizes.small
                label2.text: _projectManager.process.processRunning ? _projectManager.process.infoLabel :  _projectManager.projectPath
                imageSource: _projectManager.projectLogo
                imageSizeHint: Maui.Style.iconSizes.medium
                iconVisible: root.isWide
            }


            ProgressBar
            {
                id: _progress
                width: parent.width
                anchors.centerIn: parent
                visible: _projectManager.process.configureRunning || _projectManager.process.buildRunning
                indeterminate: true

                contentItem: Item {
                    x: _progress.leftPadding
                    y: _progress.topPadding
                    width: _progress.availableWidth
                    height: _progress.availableHeight

                    scale: _progress.mirrored ? -1 : 1

                    Repeater {
                        model: 2

                        Rectangle {
                            property real offset: 0

                            x: (_progress.indeterminate ? offset * parent.width : 0)
                            y: (parent.height - height) / 2
                            width: offset * (parent.width - x)
                            height: 4

                            color: "violet"

                            SequentialAnimation on offset {
                                loops: Animation.Infinite
                                running: _progress.indeterminate && _progress.visible
                                PauseAnimation { duration: index ? 520 : 0 }
                                NumberAnimation {
                                    easing.type: Easing.OutCubic
                                    duration: 1240
                                    from: 0
                                    to: 1
                                }
                                PauseAnimation { duration: index ? 0 : 520 }
                            }
                        }
                    }
                }

                background: null
            }
        }

        MouseArea
        {
            id: _runButton
            Layout.fillHeight: true
            Layout.preferredWidth: height * 1.5
            opacity: enabled ? 1 : 0.4
            hoverEnabled: true

            enabled: !_projectManager.process.buildRunning
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

            Kirigami.ShadowedRectangle
            {
                anchors.fill: parent
                color: Qt.lighter(Kirigami.Theme.backgroundColor)
                corners
                {
                    topLeftRadius: 0
                    topRightRadius: Maui.Style.radiusV
                    bottomLeftRadius: 0
                    bottomRightRadius: Maui.Style.radiusV
                }

                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: _projectManager.process.binaryRunning ? "media-playback-stop" : "media-playback-start"
                    color: _runButton.containsMouse || _runButton.containsPress ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor
                    width: Maui.Style.iconSizes.small
                    height: width
                }
            }
        }
    }
}
