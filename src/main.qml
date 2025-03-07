import QtQuick
import QtQml
import QtCore

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.slike.strike as Strike

import "views"
import "views/editor"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root
    title: currentEditor ? currentTab.title : ""

    property alias project : _project
    readonly property alias manager : _project.manager

    readonly property alias currentTab : editorView.currentTab
    readonly property alias currentEditor: editorView.currentEditor
    readonly property alias dialog : _dialogLoader.item

    readonly property font defaultFont:
    {
        family: "Monospace"
        pointSize: Maui.Style.fontSizes.default
    }

    //Global editor props
    property alias appSettings: settings

    readonly property Strike.CMakeProject _cmakeProject : _project.manager.project

    Maui.WindowBlur
    {
        view: root
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        windowRadius: Maui.Style.radiusV
        enabled: !Maui.Handy.isMobile
    }

    Settings
    {
        id: settings
        category: "General"

        property bool showLineNumbers : true
        property bool autoSave : true
        property bool supportSplit :true
        property double tabSpace: 8
        property string theme : ""
        property color backgroundColor : root.Maui.Theme.backgroundColor
        property color textColor : root.Maui.Theme.textColor
        property bool enableSidebar: true
        property font font : defaultFont
    }

    Strike.Project
    {
        id: _project
        preferences.installPrefix: "/usr"

        onProjectUrlChanged:
        {
            _initialConfigDialog.open()
            editorView.openTab(projectUrl)
        }
    }

    onCurrentEditorChanged:
    {
        syncSidebar(currentEditor.fileUrl)
        editorView.outputPanel.syncTerminal(currentEditor.fileUrl)
    }

    onClosing: (close) =>
    {
        _dialogLoader.sourceComponent = _unsavedDialogComponent

        dialog.callback = function ()
        {
            dialog.discard = true
            root.close()
        }

        if(!dialog.discard)
        {
            for(var i = 0; i < editorView.count; i++)
            {
                if(editorView.tabHasUnsavedFiles(i))
                {
                    close.accepted = false
                    dialog.open()
                    return
                }
            }
        }

        close.accepted = true
    }

    Action
    {
        id: _openProjectAction
        icon.name: "folder"
        text: i18n("Open Project")

        onTriggered: openFileDialog_project()
    }

    Action
    {
        id: _cloneProjectAction
        icon.name: "vcs-merge-request"
        text: i18n("Clone Project")

        onTriggered:
        {
            _dialogLoader.sourceComponent = _gitCloneDialogComponent
            dialog.open()
        }
    }

    Action
    {
        id: _openFileAction
        icon.name: "text-plain"
        text: i18n("Open File")

        onTriggered: openFileDialog_file()
    }

    Widgets.ProjectConfigDialog
    {
        id: _initialConfigDialog

        filling: !root.isWide
        maxHeight: 400
        maxWidth: 350
        hint: 1
    }

    Loader
    {
        id: _dialogLoader
    }


    Component
    {
        id: _gitCloneDialogComponent

        Maui.InputDialog
        {
            title: i18n("Clone")
            message: i18n("Enter the project Git URL")
            textEntry.placeholderText: "git@invent.kde.org:maui/mauikit.git"
            template.iconSource: "git"
            template.iconSizeHint: Maui.Style.iconSizes.huge
            template.iconVisible: true
            //            acceptButton.text: i18n("Clone")
        }
    }

    Component
    {
        id: _unsavedDialogComponent

        Maui.InfoDialog
        {
            property bool discard : false
            property var callback : ({})

            title: i18n("Unsaved files")
            message: i18n("You have unsaved files. Do you want to go back and save them or discard all changes and exit?")

            template.iconSource: "emblem-warning"

            standardButtons: Dialog.Ok | Dialog.Discard

            onDiscarded:
            {
                if(callback instanceof Function)
                {
                    callback()
                }
                close()
            }

            onAccepted: close()
        }
    }

    Component
    {
        id: _settingsDialogComponent
        Widgets.SettingsDialog
        {}
    }

    Component
    {
        id: _fileDialogComponent
        FB.FileDialog
        {
            browser
            {
                settings.onlyDirs: false
                settings.sortBy: FB.FMList.MODIFIED
            }
        }
    }

    Component
    {
        id: _tagsDialogComponent
        FB.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
            taglist.strict: false
        }
    }

    Maui.SideBarView
    {
        id: _sideBarView

        anchors.fill: parent

        sideBar.preferredWidth: Maui.Style.units.gridUnit*16
        sideBar.minimumWidth: Maui.Style.units.gridUnit*14
        sideBar.enabled: editorView.count > 0 &&  settings.enableSidebar

        Connections
        {
            target: _sideBarView.sideBar
            function onVisibleChanged()
            {
                if(currentEditor)
                    syncSidebar(currentEditor.fileUrl)
            }
        }

        sideBarContent: PlacesSidebar
        {
            id : _drawer
            anchors.fill: parent
        }

        DropArea
        {
            id: _dropArea
            property var urls : []
            anchors.fill: parent
            onDropped:
            {
                if(drop.urls)
                {
                    var m_urls = drop.urls.join(",")
                    _dropArea.urls = m_urls.split(",")
                    Strike.Strike.requestFiles( _dropArea.urls )
                }
            }
        }

        EditorView
        {
            id: editorView
            anchors.fill: parent
            Maui.Controls.showCSD: true

            headBar.forceCenterMiddleContent: false

            headBar.farLeftContent: ToolButton
            {
                visible: _sideBarView.sideBar.enabled
                Layout.minimumWidth: implicitWidth
                Layout.alignment: Qt.AlignLeft
                icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
                onClicked: _sideBarView.sideBar.toggle()

                checked: _sideBarView.sideBar.visible

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: i18n("Toogle SideBar")
            }

            headBar.rightContent: [

                Maui.ToolButtonMenu
                {
                    icon.name: "list-add"


                    MenuItem
                    {
                        icon.name: "applications-development"
                        text: i18n("Create New Project")

                        onTriggered:
                        {

                        }
                    }

                    MenuItem
                    {
                        action: _openProjectAction
                    }

                    MenuItem
                    {
                        action: _cloneProjectAction
                    }

                    MenuItem
                    {
                       action: _openFileAction
                    }

                    MenuItem
                    {
                        icon.name: "text-enriched"
                        text: i18n("New Template Source File")

                        onTriggered:
                        {
                            editorView.openTab("")
                            //                _editorListView.currentItem.body.textFormat = TextEdit.RichText
                        }
                    }
                    MenuSeparator{}
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
                        onTriggered: Maui.App.aboutDialog()
                    }
                }
            ]

            headBar.middleContent: Widgets.BuildBar
            {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Layout.maximumWidth: 300
                Layout.minimumWidth: 0
            }

        }
    }

    Connections
    {
        target: Strike.Strike
        function onOpenFiles(urls)
        {
            for(var i in urls)
                editorView.openTab(urls[i])
        }
    }

    function syncSidebar(path)
    {
        if(path && FB.FM.fileExists(path))
        {
            _drawer.browser.openFolder(FB.FM.fileDir(path))
        }
    }

    function openFileDialog_project()
    {
            _dialogLoader.sourceComponent = _fileDialogComponent
            dialog.mode = FB.FileDialog.Modes.Open
            dialog.singleSelection = true
            dialog.browser.settings.filterType = FB.FMList.NONE
            dialog.browser.settings.filters = ["CMakeLists.txt"]
            dialog.callback = function (urls)
            {
                _project.projectUrl = urls[0]
            }
            dialog.open()
    }

    function openFileDialog_file()
    {
        _dialogLoader.sourceComponent = _fileDialogComponent
        dialog.mode = FB.FileDialog.Modes.Open
        dialog.singleSelection = false
        dialog.browser.settings.filterType = FB.FMList.TEXT
        dialog.browser.settings.filters = []
        dialog.callback =  function (urls)
        {
            for(var url of urls)
            {
                editorView.openTab(url)
            }
        }
        dialog.open()
    }
}
