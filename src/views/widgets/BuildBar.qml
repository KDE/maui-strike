import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.slike.strike 1.0 as Strike

Item
{
    id: control

    implicitHeight: Maui.Style.rowHeight

    enabled: _project.manager.status === Strike.Manager.Ready

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
                //                _project.process.build()
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

            onClicked : _projectMenu.open()

            contentItem: Maui.ListItemTemplate
            {
                label1.text: _cmakeProject.title
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                label2.font.pointSize: Maui.Style.fontSizes.small
                label2.text: _project.projectPath
                imageSource: _project.projectLogo
                imageSizeHint: Maui.Style.iconSizes.medium
                iconVisible: root.isWide

                Kirigami.Icon
                {
                    source: "go-down"
                    implicitHeight: Maui.Style.iconSizes.small
                    implicitWidth: implicitHeight
                }
            }

            Maui.Popup
            {

                id: _projectMenu
                maxHeight: 200
                maxWidth:  parent.width

                ColumnLayout
                {
                    anchors.fill: parent

                    Maui.ListBrowser
                    {
                        id: _projectsListView
                        Layout.fillWidth: true
                        model: _project.manager.projectsModel

                        delegate: Maui.ListBrowserDelegate
                        {
                            width: ListView.view.width
                            iconSource: "alienarena"
                            label1.text: model.title
                            onClicked:
                            {
                                _projectsListView.currentIndex = index
                                _cmakeProject.data = model.data
                            }
                        }
                    }

                    Maui.LabelDelegate
                    {
                        Layout.fillWidth: true
                        label: i18n("Targets")
                        isSection: true
                    }

                    Maui.ListBrowser
                    {
                        id: _targetsListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: _cmakeProject.targetsModel

                        delegate: Maui.ListBrowserDelegate
                        {
                            width: ListView.view.width
                            iconSource: "run-build"
                            label1.text: model.name
                            label2.text: model.type

                            onClicked:
                            {
                                _targetsListView.currentIndex = index
                                _cmakeProject.target.setData(model.target)
                            }
                        }
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
            id: _menuButton
            Layout.fillHeight: true
            Layout.preferredWidth: height * 1.5
            opacity: enabled ? 1 : 0.4
            hoverEnabled: true
            onClicked: _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)

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
                source: "overflow-menu"
                width: Maui.Style.iconSizes.small
                height: width
            }

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

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Settings")
                    icon.name: "settings-configure"
                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _settingsDialogComponent
                        dialog.open()
                    }
                }

                MenuItem
                {
                    text: i18n("About")
                    icon.name: "documentinfo"
                    onTriggered: root.about()
                }
            }


        }
    }
}
