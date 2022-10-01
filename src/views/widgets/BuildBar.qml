import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.slike.strike 1.0 as Strike

Control
{
    id: control

    implicitHeight: _layout.implicitHeight + topPadding + bottomPadding

    padding: 0
    background: null

    //    enabled: _project.manager.status === Strike.Manager.Ready
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

    contentItem: RowLayout
    {
        id: _layout
        spacing: 2

        AbstractButton
        {
            id: _buildButton

            Maui.Theme.colorSet: Maui.Theme.Button
            Maui.Theme.inherit: false

            Layout.fillHeight: true
            Layout.preferredWidth: height * 1.5

            opacity: enabled ? 1 : 0.4
            hoverEnabled: true
            //            enabled: !manager.process.processRunning
            onClicked:
            {
                if(manager.process.processRunning)
                {
                    if(manager.process.deployStatus === Strike.Process.Running)
                    {
                        manager.process.stopDeploy()
                    }
                }else
                {
                    _execMenu.show(0, height + Maui.Style.space.medium)
                }
            }

            background: Kirigami.ShadowedRectangle
            {
                color: Maui.Theme.backgroundColor
                corners
                {
                    topLeftRadius: Maui.Style.radiusV
                    topRightRadius: 0
                    bottomLeftRadius: Maui.Style.radiusV
                    bottomRightRadius: 0
                }
            }

            contentItem: Item
            {
                Kirigami.Icon
                {
                    anchors.centerIn: parent
                    source: manager.process.processRunning ? "media-playback-stop" : "run-build"

                    color: _buildButton.containsMouse || _buildButton.containsPress ? control.Maui.Theme.highlightColor : control.Maui.Theme.textColor
                    width: Maui.Style.iconSizes.small
                    height: width
                }
            }

            Maui.ContextualMenu
            {
                id:  _execMenu

                MenuItem
                {
                    text:i18n("Configure")
                    icon.name: "run-build-configure"
                    onTriggered: manager.process.configure()
                }

                MenuItem
                {
                    text:i18n("Build")
                    icon.name: "run-build"
                    onTriggered: manager.process.build()
                }

                MenuItem
                {
                    text:i18n("Run")
                    icon.name: "media-playback-start"
                    onTriggered: manager.process.deploy()
                }

                MenuItem
                {
                    text:i18n("Install")
                    icon.name: "run-install"
                    onTriggered: {}
                }
            }
        }

        AbstractButton
        {
            id: _menuButton
            Layout.fillWidth: true
            Layout.fillHeight: true

            Maui.Theme.colorSet: Maui.Theme.Button
            Maui.Theme.inherit: false

            implicitHeight: _template.implicitHeight + topPadding + bottomPadding

            leftPadding: Maui.Style.space.small
            rightPadding: leftPadding
            padding: 0

            background: Kirigami.ShadowedRectangle
            {
                color: Maui.Theme.backgroundColor
                border.width: 1
                border.color: _docMenu.visible ? Maui.Theme.highlightColor : color
                corners
                {
                    topLeftRadius: 0
                    topRightRadius: Maui.Style.radiusV
                    bottomLeftRadius: 0
                    bottomRightRadius: Maui.Style.radiusV
                }

                ProgressBar
                {
                    id: _progress
                    width: parent.width
                    anchors.bottom: parent.bottom
                    visible: manager.process.processRunning
                    indeterminate: true

                    contentItem: Item
                    {
                        x: _progress.leftPadding
                        y: _progress.topPadding
                        width: _progress.availableWidth
                        height: _progress.availableHeight

                        scale: _progress.mirrored ? -1 : 1

                        Repeater
                        {
                            model: 2

                            Rectangle
                            {
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

            onClicked: _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)

            indicator: Kirigami.Icon
            {
                x: _menuButton.width - width - _menuButton.rightPadding
                y: _menuButton.topPadding + (_menuButton.availableHeight - height) / 2

                implicitHeight: 8
                implicitWidth: 8
                rotation: 90
                source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/Material/images/arrow-indicator.png"


                color: Maui.Theme.textColor
            }


            contentItem: Maui.ListItemTemplate
            {
                id: _template
                label1.text: _cmakeProject.title || root.title
                label1.horizontalAlignment: Qt.AlignHCenter
                label2.horizontalAlignment: Qt.AlignHCenter
                //                label2.font.pointSize: Maui.Style.fontSizes.small
                //                label2.text: manager.process.infoLabel || _project.projectPath
                imageSource: _project.projectLogo
                imageSizeHint: Maui.Style.iconSizes.medium
                iconVisible: root.isWide
            }

            Maui.ContextualMenu
            {
                id: _docMenu

                Maui.MenuItemActionRow
                {
                    Action
                    {
                        icon.name: "edit-undo"
                        //                        text: i18n("Undo")
                        enabled: currentEditor.body.canUndo
                        onTriggered: currentEditor.body.undo()
                    }

                    Action
                    {
                        icon.name: "edit-redo"
                        //                        text: i18n("Redo")
                        enabled: currentEditor.body.canRedo
                        onTriggered: currentEditor.body.redo()
                    }


                    Action
                    {
                        //                        text: i18n("Save")
                        icon.name: "document-save"
                        enabled: currentEditor ? currentEditor.document.modified : false
                        onTriggered: saveFile( control.currentEditor.fileUrl, control.currentEditor)
                    }

                    Action
                    {
                        icon.name: "document-save-as"
                        //                        text: i18n("Save as...")
                        onTriggered: saveFile("", control.currentEditor)
                    }
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Split")
                    visible: settings.supportSplit
                    icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                    checked: root.currentTab && root.currentTab.count === 2
                    checkable: true
                    onTriggered:
                    {
                        if(root.currentTab.count === 2)
                        {
                            root.currentTab.pop()
                            return
                        }//close the inactive split

                        root.currentTab.split("")
                    }
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

                Maui.MenuItemActionRow
                {
                    Action
                    {
                        //                        text: i18n("Share")
                        icon.name: "document-share"
                        onTriggered: Maui.Platform.shareFiles([currentEditor.fileUrl])

                    }

                    Action
                    {
                        //                        text: i18n("Show in folder")
                        icon.name: "folder-open"
                        onTriggered:
                        {
                            FB.FM.openLocation([currentEditor.fileUrl])
                        }
                    }

                    Action
                    {
                        //                        text: i18n("Info")
                        icon.name: "documentinfo"
                        onTriggered:
                        {
                            //            getFileInfo(control.model.get(index).url)
                        }
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
