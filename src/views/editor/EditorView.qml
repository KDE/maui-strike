import QtQuick 2.14
import QtQuick.Controls 2.13

import org.kde.kirigami 2.14 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import QtQuick.Window 2.0

import "../widgets"

Maui.Page
{
    id: control

    readonly property alias count: _editorListView.count

    property alias currentTab : _editorListView.currentItem
    readonly property TE.TextEditor currentEditor: currentTab ? currentTab.currentItem.editor : null
    property alias listView: _editorListView
    property alias model : _editorListView.contentModel
    property alias tabView : _editorListView

    property alias outputPanel :_outputPanel

    Component
    {
        id: _gitCloneDialogComponent

        Maui.NewDialog
        {
            title: i18n("Clone")
            message: i18n("Enter the project Git URL")
            textEntry.placeholderText: "git@invent.kde.org:maui/mauikit.git"
            template.iconSource: "git"
            template.iconSizeHint: Maui.Style.iconSizes.huge
            template.iconVisible: true
            acceptButton.text: i18n("Clone")
        }
    }

    Maui.SplitView
    {
        anchors.fill: parent
        spacing: 0
        orientation: Qt.Vertical

        Maui.TabView
        {
            id: _editorListView

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            tabBar.visible: currentEditor
            tabBar.showNewTabButton: false

            tabBar.rightContent: ToolButton
            {
                text: i18n("Split")
                visible: settings.supportSplit
                icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                checked: root.currentTab && root.currentTab.count === 2
                checkable: true
                onClicked:
                {
                    if(control.currentTab.count === 2)
                    {
                        control.currentTab.pop()
                        return
                    }//close the inactive split

                    control.currentTab.split("")
                }
            }

            holder.emoji: "qrc:/img/draw-calligraphic.svg"

            holder.title: i18n("Missing Project")
            holder.body: i18n("Create or open a new project.")

            holder.actions: [
                Action
                {
                    icon.name: "folder-open"
                    text: i18n("Open Project")

                    onTriggered:
                    {

                        _dialogLoader.sourceComponent = _fileDialogComponent
                        dialog.mode = dialog.modes.OPEN
                        //            dialog.singleSelection = true
                        dialog.settings.filters = ["*.txt"]
                        dialog.callback =  function (urls)
                        {
                            _project.projectUrl = urls[0]
                        }
                        dialog.open()
                        control.close()
                    }
                },

                Action
                {
                    icon.name: "vcs-merge-request"
                    text: i18n("Clone Project")

                    onTriggered:
                    {
                        _dialogLoader.sourceComponent = _gitCloneDialogComponent
                        dialog.open()
                    }
                }
            ]

            onNewTabClicked: control.openTab("")
            onCloseTabClicked:
            {
                if( tabHasUnsavedFiles(index) )
                {
                    _dialogLoader.sourceComponent = _unsavedDialogComponent
                    dialog.callback = function () { closeTab(index) }

                    if(tabHasUnsavedFiles(index))
                    {
                        dialog.open()
                        return
                    }
                }
                else
                    closeTab(index)
            }

            tabViewButton: Maui.TabViewButton
            {
                id:  _tabButton
                tabView: _editorListView
                onClicked:
                {
                    if(_tabButton.mindex === _editorListView.currentIndex)
                    {
                        _docMenu.show((width*0.5)-(_docMenu.width*0.5), height + Maui.Style.space.medium)
                        return
                    }

                    _editorListView.setCurrentIndex(_tabButton.mindex)
                    _editorListView.currentItem.forceActiveFocus()
                }

                onCloseClicked:
                {
                    _editorListView.closeTabClicked(_tabButton.mindex)
                }

                rightContent: Maui.Icon
                {
                    visible: _tabButton.checked
                    source: "overflow-menu"
                    height: Maui.Style.iconSizes.small
                    width: height
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
                            enabled: currentEditor && currentEditor.body.canUndo
                            onTriggered: currentEditor.body.undo()
                        }

                        Action
                        {
                            icon.name: "edit-redo"
                            //                        text: i18n("Redo")
                            enabled: currentEditor && currentEditor.body.canRedo
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


                }
            }
        }

        OutputPanel
        {
            id: _outputPanel
            visible: _editorListView.count > 0
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : Maui.Style.space.big
        }

        handle: Kirigami.ShadowedRectangle
        {
            Maui.Theme.inherit: false
            Maui.Theme.colorSet: Maui.Theme.Complementary
            Maui.Theme.backgroundColor: "#2c2c2c"

            implicitWidth: 22
            implicitHeight: Maui.Style.toolBarHeight
            color: Maui.Theme.backgroundColor

            corners
            {
                topLeftRadius: 10
                topRightRadius: 10
                bottomLeftRadius: 0
                bottomRightRadius: 0
            }

            Maui.ToolActions
            {
                anchors.centerIn: parent
                anchors.leftMargin:  Maui.Style.space.medium
                anchors.rightMargin:  Maui.Style.space.medium

                Action
                {
                    icon.name: "dialog-scripts"
                    checked:  _outputPanel.currentIndex === 0
                    onTriggered: _outputPanel.currentIndex = 0
                }

                Action
                {
                    icon.name: "love"
                    checked:  _outputPanel.currentIndex === 1
                    onTriggered: _outputPanel.currentIndex = 1
                }

                Action
                {
                    icon.name: "git"
                    checked:  _outputPanel.currentIndex === 2
                    onTriggered: _outputPanel.currentIndex = 2
                }
            }
        }
    }


    Component
    {
        id: _editorLayoutComponent
        EditorLayout {}
    }


    function unsavedTabSplits(index) //which split indexes are unsaved
    {
        var indexes = []
        const tab =  control.model.get(index)
        for(var i = 0; i < tab.count; i++)
        {
            if(tab.model.get(i).editor.document.modified)
            {
                indexes.push(i)
            }
        }
        return indexes
    }

    function tabHasUnsavedFiles(index) //if a tab has at least one unsaved file in a split
    {
        return unsavedTabSplits(index).length
    }

    function fileIndex(path) //find the [tab, split] index for a path
    {
        if(path.length === 0)
        {
            return [-1, -1]
        }

        for(var i = 0; i < control.count; i++)
        {
            const tab =  control.model.get(i)
            for(var j = 0; j < tab.count; j++)
            {
                const doc = tab.model.get(j)
                if(doc.fileUrl.toString() === path)
                {
                    return [i, j]
                }
            }
        }
        return [-1,-1]
    }

    function openTab(path)
    {
        const index = fileIndex(path)

        if(index[0] >= 0)
        {
            _editorListView.currentIndex = index[0]
            currentTab.currentIndex = index[1]
            return
        }

        _editorListView.addTab(_editorLayoutComponent, {"path": path})
        _historyList.append(path)

    }

    function closeTab(index) //no questions asked
    {
        _editorListView.closeTab(index)
    }

    function saveFile(path, item)
    {
        if(!item)
            return

        if (path && FB.FM.fileExists(path))
        {
            item.document.saveAs(path)
        } else
        {
            _dialogLoader.sourceComponent = _fileDialogComponent
            dialog.mode = dialog.modes.SAVE;
            //            fileDialog.settings.singleSelection = true
            dialog.callback = function (paths)
            {
                item.document.saveAs(paths[0])
                _historyList.append(paths[0])
            };

            dialog.open()
        }
    }

}
