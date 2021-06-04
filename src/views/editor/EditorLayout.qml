import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.nota 1.0 as Nota

Item
{
    id: control

    height: ListView.view.height
    width: ListView.view.width

    property url path

    property alias currentIndex : _splitView.currentIndex
    property alias orientation : _splitView.orientation

    readonly property alias count : _splitView.count
    readonly property alias currentItem : _splitView.currentItem
    readonly property alias model : _splitView.contentModel
    readonly property string title : count === 2 ?  model.get(0).title + "  -  " + model.get(1).title : currentItem.title

    Maui.TabViewInfo.tabTitle: title
    Maui.TabViewInfo.tabToolTipText:  currentItem.fileUrl

    readonly property alias editor : _splitView.currentItem
    readonly property alias terminal : terminalLoader.item
    property bool terminalVisible : false

    Keys.enabled: true
    Keys.onPressed:
    {
        if(event.key === Qt.Key_F3)
        {
            if(control.count === 2)
            {
                pop()
                return
            }//close the inactive split

            split("")
        }

        if((event.key === Qt.Key_Space) && (event.modifiers & Qt.ControlModifier))
        {
            console.log("KEYS PRESSED ON TABS LAYOUT OPEN TABS SEARCGH")

            tabView.findTab()
        }


        if(event.key === Qt.Key_F4)
        {
            control.terminalVisible = !control.terminalVisible
        }
    }


    Maui.SplitView
    {
        anchors.fill: parent
        orientation: Qt.Vertical

        Maui.SplitView
        {
            id: _splitView

            SplitView.fillHeight: true
            SplitView.fillWidth: true

            orientation : width >= 600 ? Qt.Horizontal : Qt.Vertical

            onCurrentItemChanged: syncTerminal(control.editor.fileUrl)

            Component.onCompleted: split(control.path)
        }

        Loader
        {
            id: terminalLoader
            asynchronous: true
            active: settings.supportTerminal && Nota.Nota.supportsEmbededTerminal()
            visible: active && control.terminalVisible
            SplitView.fillWidth: true
            SplitView.preferredHeight: 200
            SplitView.maximumHeight: parent.height * 0.5
            SplitView.minimumHeight : 100
            source: "../Terminal.qml"
            onLoaded: syncTerminal(control.currentEditor.fileUrl)

            Behavior on SplitView.preferredHeight
            {
                NumberAnimation
                {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
            }
        }
    }

    Component
    {
        id: _editorComponent

        Editor {}
    }

    function syncTerminal(path)
    {
        if(control.terminal && control.terminal.visible && FB.FM.fileExists(path))
            control.terminal.session.sendText("cd '" + String(FB.FM.fileDir(path)).replace("file://", "") + "'\n")
    }

    function toggleTerminal()
    {
        control.terminalVisible = !control.terminalVisible
    }

    function split(path)
    {
        if(_splitView.count === 1 && !settings.supportSplit)
        {
            return
        }

        if(_splitView.count === 2)
        {
            return
        }

        _splitView.addSplit(_editorComponent, {'fileUrl': path})
    }

    function pop()
    {
        if(_splitView.count === 1)
        {
            return //can not pop all the browsers, leave at leats 1
        }

        closeSplit(_splitView.currentIndex === 1 ? 0 : 1)
    }

    function closeSplit(index) //closes a split but triggering a warning before
    {
        if(index >= _splitView.count)
        {
            return
        }

        const item = _splitView.itemAt(index)
        if( item.document.modified)
        {
            _dialogLoader.sourceComponent = _unsavedDialogComponent
            dialog.callback = function () { destroyItem(index) }
            dialog.open()
            return
        } else
        {
            destroyItem(index)
        }
    }

    function destroyItem(index) //deestroys a split view withouth warning
    {
        _splitView.closeSplit(index)
    }
}


