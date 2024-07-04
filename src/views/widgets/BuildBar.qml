import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.slike.strike as Strike

Control
{
    id: control

    implicitHeight: _layout.implicitHeight + topPadding + bottomPadding
    implicitWidth: _layout.implicitWidth +leftPadding + rightPadding

    padding: 0
    background: null

    //    enabled: _project.manager.status === Strike.Manager.Ready
    Popup
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
                text: i18n("Targets")
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

        Maui.ToolButtonMenu
        {
            id: _buildButton
            enabled: project.active
            Layout.fillHeight: true
            icon.name: manager.process.processRunning ? "media-playback-stop" : "run-build"

            onClicked:
            {
                if(manager.process.processRunning)
                {
                    if(manager.process.deployStatus === Strike.Process.Running)
                    {
                        manager.process.stopDeploy()
                    }
                }
            }

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

            background: Maui.ShadowedRectangle
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
        }

        Maui.ToolButtonMenu
        {
            id: _menuButton
            Layout.fillHeight: true
            Layout.fillWidth: true
            icon.source: _project.projectLogo
            icon.color: "transparent"
            enabled: currentEditor
            font.bold: true
            font.weight: Font.Bold
            //icon.height: Maui.Style.iconSizes.medium
            //icon.width:  Maui.Style.iconSizes.medium
            text: _cmakeProject.title.length > 0 ? _cmakeProject.title : Maui.App.about.displayName
            display: ToolButton.TextBesideIcon


            menu.title: _cmakeProject.title
            menu.titleImageSource: _project.projectLogo

            Maui.LabelDelegate
            {
                text: i18n("Targets")
                isSection:true
            }

            Repeater
            {
                model: 3

                MenuItem
                {
                    text: "target " + index
                    checkable: true
                }
            }

            MenuSeparator{}

            MenuItem
            {
                text: i18n("Clear CMake")
            }


            MenuSeparator{}

            MenuItem
            {
                text: i18n("Open directory")
            }

            MenuItem
            {
                text: i18n("Configure")
            }

            MenuItem
            {
                text: i18n("Close")
            }

            background: Maui.ShadowedRectangle
            {
                color: Maui.Theme.backgroundColor
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
        }
    }
}
