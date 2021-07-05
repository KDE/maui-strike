import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

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

        AbstractButton
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

           background: Kirigami.ShadowedRectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)

                corners
                {
                    topLeftRadius: Maui.Style.radiusV
                    topRightRadius: 0
                    bottomLeftRadius: Maui.Style.radiusV
                    bottomRightRadius: 0
                }
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


        AbstractButton
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            background: Rectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)
                border.width: 1
                border.color: _docMenu.visible ? Kirigami.Theme.highlightColor : color
            }

            contentItem: Maui.ListItemTemplate
            {
                label1.text:  _projectManager.projectTitle
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                label2.font.pointSize: Maui.Style.fontSizes.small
                label2.text: _projectManager.process.processRunning ? _projectManager.process.infoLabel :  _projectManager.projectPath
                imageSource: _projectManager.projectLogo
                imageSizeHint: Maui.Style.iconSizes.medium
                iconVisible: root.isWide

                Kirigami.Icon
                {
                    source: "go-down"
                    implicitHeight: Maui.Style.iconSizes.small
                    implicitWidth: implicitHeight
                }
            }

            onClicked: _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)

            Maui.ContextualMenu
            {
                id: _docMenu

                MenuItem
                {
                    icon.name: "edit-undo"
                    text: i18n("Undo")
                    enabled: currentEditor.body.canUndo
                    onTriggered: currentEditor.body.undo()
                }

                MenuItem
                {
                    icon.name: "edit-redo"
                    text: i18n("Redo")
                    enabled: currentEditor.body.canRedo
                    onTriggered: currentEditor.body.redo()
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Save")
                    icon.name: "document-save"
                    enabled: currentEditor ? currentEditor.document.modified : false
                    onTriggered: saveFile( control.currentEditor.fileUrl, control.currentEditor)
                }

                MenuItem
                {
                    icon.name: "document-save-as"
                    text: i18n("Save as...")
                    onTriggered: saveFile("", control.currentEditor)
                }

                MenuSeparator {}

                MenuItem
                {
                    icon.name: "edit-find"
                    text: i18n("Find and Replace")
                    checkable: true

                    onTriggered:
                    {
                        currentEditor.showFindBar = !currentEditor.showFindBar
                    }
                    checked: currentEditor.showFindBar
                }

                MenuItem
                {
                    icon.name: "document-edit"
                    text: i18n("Line/Word Counter")
                    checkable: true

                    onTriggered:
                    {
                        currentEditor.showLineCount = checked
                    }

                    checked: currentEditor.showLineCount
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Share")
                    icon.name: "document-share"
                    onTriggered: Maui.Platform.shareFiles([currentEditor.fileUrl])

                }

                MenuItem
                {
                    text: i18n("Open with")
                    icon.name: "document-open"
                }

                MenuItem
                {
                    visible: !Maui.Handy.isAndroid
                    text: i18n("Show in folder")
                    icon.name: "folder-open"
                    onTriggered:
                    {
                        FB.FM.openLocation([currentEditor.fileUrl])
                    }
                }

                MenuItem
                {
                    text: i18n("Info")
                    icon.name: "documentinfo"
                    onTriggered:
                    {
            //            getFileInfo(control.model.get(index).url)
                    }
                }

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

        AbstractButton
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

            background: Kirigami.ShadowedRectangle
            {
                color: Qt.lighter(Kirigami.Theme.backgroundColor)
                corners
                {
                    topLeftRadius: 0
                    topRightRadius: Maui.Style.radiusV
                    bottomLeftRadius: 0
                    bottomRightRadius: Maui.Style.radiusV
                }
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
