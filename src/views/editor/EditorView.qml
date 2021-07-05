import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import QtQuick.Window 2.0

import "../widgets"

Item
{
    id: control

    readonly property alias count: _editorListView.count

    property alias currentTab : _editorListView.currentItem
    readonly property TE.TextEditor currentEditor: currentTab ? currentTab.currentItem.editor : null
    property alias listView: _editorListView
    property alias model : _editorListView.contentModel
    property alias tabView : _editorListView

    property alias outputPanel :_outputPanel


    SplitView
    {
        anchors.fill: parent
        spacing: 0
        orientation: Qt.Vertical


        Maui.TabView
        {
            id: _editorListView

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            holder.emoji: "qrc:/img/draw-calligraphic.svg"

            holder.title: i18n("Missing Project")
            holder.body: i18n("Create or open a new project.")

            holder.actions: Action
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
                        _projectManager.projectUrl = urls[0]
                    }
                    dialog.open()
                    control.close()
                }
            }

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
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
            Kirigami.Theme.backgroundColor: "#2c2c2c"

            implicitWidth: 22
            implicitHeight: Maui.Style.toolBarHeight
            color: Kirigami.Theme.backgroundColor

            corners
            {
                topLeftRadius: 10
                topRightRadius: 10
                bottomLeftRadius: 0
                bottomRightRadius: 0
            }

            RowLayout
            {
                anchors.fill: parent
                anchors.leftMargin:  Maui.Style.space.medium
                anchors.rightMargin:  Maui.Style.space.medium

                ToolButton
                {
                    Layout.minimumWidth: implicitWidth
                    Layout.alignment: Qt.AlignLeft
                    visible: settings.enableSidebar
                    icon.name: _drawer.visible ? "sidebar-collapse" : "sidebar-expand"
                    onClicked: _drawer.toggle()

                    checked: _drawer.visible

                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Toogle SideBar")
                }

                Maui.ToolActions
                {
                    Layout.minimumWidth: implicitWidth
                    Layout.alignment: Qt.AlignCenter

                    currentIndex : _outputPanel.currentIndex
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
                }

                ToolButton
                {
                    Layout.minimumWidth: implicitWidth
                    Layout.alignment: Qt.AlignRight

                    visible: settings.supportSplit
                    icon.name: root.currentTab.orientation === Qt.Horizontal ? "view-split-left-right" : "view-split-top-bottom"
                    checked: root.currentTab && root.currentTab.count === 2
                    checkable: true
                    onClicked:
                    {
                        if(root.currentTab.count === 2)
                        {
                            root.currentTab.pop()
                            return
                        }//close the inactive split

                        root.currentTab.split("")
                    }
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
