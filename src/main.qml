import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
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

    altHeader: Kirigami.Settings.isMobile
    headBar.visible: !focusMode

    property alias currentTab : editorView.currentTab
    property alias currentEditor: editorView.currentEditor
    property alias dialog : _dialogLoader.item

    property bool focusMode : false

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.default
    }

    //Global editor props
    property alias appSettings: settings

    Settings
    {
        id: settings
        category: "General"

        property bool enableSidebar : false
        property bool showLineNumbers : true
        property bool autoSave : true
        property bool enableSyntaxHighlighting : true
        property bool showSyntaxHighlightingLanguages: false
        property bool supportSplit :true
        property bool supportTerminal : true
        property double tabSpace: 8
        property string theme : ""
        property color backgroundColor : root.Kirigami.Theme.backgroundColor
        property color textColor : root.Kirigami.Theme.textColor

        property font font : defaultFont
    }

    Strike.ProjectManager
    {
        id: _projectManager
        process.installPrefix: "/usr"

        onProjectUrlChanged:
        {
            editorView.openTab(projectUrl)
        }
    }

    Connections
    {
        target: _projectManager.process

        function onOutputLine(output)
        {
            console.log("OUTPUT LINE", output)
            _outputArea.append(output)
        }
    }

    onCurrentEditorChanged: syncSidebar(currentEditor.fileUrl)

    mainMenu: [

        Action
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        }
        ,

        Action
        {
            text: i18n("Plugins")
            icon.name: "system-run"
            onTriggered: _plugingsDialog.open()
        }
    ]

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

    Widgets.PluginsDialog
    {
        id: _plugingsDialog
    }

    NewFileDialog
    {
        id: _newDocumentMenu
    }

    headBar.forceCenterMiddleContent: false
    headBar.leftContent: ToolButton
    {
        visible: settings.enableSidebar
        icon.name: _drawer.visible ? "sidebar-collapse" : "sidebar-expand"
        onClicked: _drawer.toggle()

        checked: _drawer.visible

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: i18n("Toogle SideBar")
    }

    headBar.rightContent: [ToolButton
        {
            id: _outputButton
            icon.name: "dialog-messages"
            checkable: true
            checked : _outputDrawer.visible
        },

        ToolButton
        {
            icon.name: "list-add"
            onClicked:
            {
                _newDocumentMenu.open()
            }
        }
    ]
    Component
    {
        id: _buildBarComponent

        Widgets.BuildBar
        {
            implicitWidth: 0
        }
    }

    headBar.middleContent: Loader
    {
        id: _buildBar1Loader
        visible: active
        active: root.width > Kirigami.Units.gridUnit * 40
        sourceComponent: _buildBarComponent
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        Layout.minimumWidth: 0
    }

    page.headerColumn: Maui.ToolBar
    {
        visible: !_buildBar1Loader.active && root.headBar.visible

        width: parent.width
        position: ToolBar.Header
        middleContent: Loader
        {
            visible: active
            active: !_buildBar1Loader.active
            sourceComponent: _buildBarComponent
            Layout.fillWidth: true
            Layout.maximumWidth: 500
        }
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

    sideBar: PlacesSidebar
    {
        id : _drawer
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
        anchors.bottomMargin: _outputDrawer.modal ? 0 : (_outputDrawer.visible ? _outputDrawer.height : 0)
        transform: Translate {
            y: _outputDrawer.modal ? (0 - (_outputDrawer.position * (_outputDrawer.height))) : 0
        }
    }

    Drawer
    {
        id: _outputDrawer
        modal: !root.isWide
        interactive: modal

        onModalChanged:
        {
            visible = !modal && _outputButton.checked
        }

        visible: _outputButton.checked
        edge: Qt.BottomEdge
        height: Math.min(200, parent.height * 0.3)
        width: parent.width

        Binding on visible {
            value: _outputButton.checked
            restoreMode: Binding.RestoreBindingOrValue
        }

        ScrollView
        {
            id: _scrollView
            anchors.fill: parent
            contentWidth: avaliableWidth

            Flickable
            {
                id: _flickable
                interactive: Kirigami.Settings.hasTransientTouchInput
                boundsBehavior: Flickable.StopAtBounds
                boundsMovement :Flickable.StopAtBounds

                TextArea.flickable:   TextArea
                {
                    id: _outputArea
                    anchors.fill: parent
                    color: "violet"
                    readOnly: true
                    background: Rectangle
                    {
                        color:  "#333"
                    }
                }
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
        if(path && FB.FM.fileExists(path) && settings.enableSidebar)
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
