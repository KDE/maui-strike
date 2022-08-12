import QtQuick 2.14
import QtQml 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.slike.strike 1.0 as Strike

import "views"
import "views/editor"
import "views/widgets" as Widgets

Maui.ApplicationWindow
{
    id: root
    title: currentEditor ? currentTab.title : ""

    property alias project : _project
    property alias manager : _project.manager

    property alias currentTab : editorView.currentTab
    property alias currentEditor: editorView.currentEditor
    property alias dialog : _dialogLoader.item

    readonly property font defaultFont:
    {
        family: "Monospace"
        pointSize: Maui.Style.fontSizes.default
    }

    //Global editor props
    property alias appSettings: settings

    property Strike.CMakeProject _cmakeProject : _project.manager.project

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

    onClosing:
    {
        _dialogLoader.sourceComponent = _unsavedDialogComponent

        dialog.callback = function () {root.close()}

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

    NewFileDialog
    {
        id: _newDocumentMenu
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
        id: _unsavedDialogComponent

        Maui.Dialog
        {
            property bool discard : false
            property var callback : ({})
            title: i18n("Unsaved files")
            message: i18n("You have unsaved files. You can go back and save them or choose to discard all changes and exit.")
            page.margins: Maui.Style.space.big
            template.iconSource: "emblem-warning"
            acceptButton.text: i18n("Go back")
            rejectButton.text: i18n("Discard")
            onRejected:
            {
                discard = true

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
            settings.onlyDirs: false
            settings.filterType: FB.FMList.TEXT
            settings.sortBy: FB.FMList.MODIFIED
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
            showCSDControls: true

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

                ToolButton
                {
                    icon.name: "list-add"
                    onClicked:
                    {
                        _newDocumentMenu.open()
                    }
                }
            ]

            headBar.middleContent: Widgets.BuildBar
            {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Layout.maximumWidth: 500
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

    function openFileDialog()
    {
        _dialogLoader.sourceComponent = _fileDialogComponent
        dialog.mode = dialog.modes.OPEN
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
