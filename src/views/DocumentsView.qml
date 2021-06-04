import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.6 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.nota 1.0 as Nota
import "widgets"

DocsBrowser
{
    id: control

    property alias list : _documentsList
    headBar.visible: true

    holder.visible: _documentsList.count === 0
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Documents!")
    holder.body: i18n("Add a new source to browse your text files")
    holder.emojiSize: Maui.Style.iconSizes.huge

    floatingFooter: true

    model: Maui.BaseModel
    {
        id: _documentsModel
        list: Nota.Documents
        {
            id: _documentsList
        }

        sort: "place"
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    listView.section.criteria: ViewSection.FullString
    listView.section.property: "place"
    listView.section.delegate: Maui.ListItemTemplate
    {
        property var item : FB.FM.getFileInfo(section)
        spacing: Maui.Style.space.medium
        width: parent.width
        height: Maui.Style.rowHeight*2
        margins: Maui.Style.space.medium
        iconSource: item.icon
        iconSizeHint: Maui.Style.iconSizes.big
        label1.text: item.label
        label2.text: item.path
        label3.text:  Maui.Handy.formatDate(Date(item.modified), "MM/dd/yyyy")
        label4.text: Maui.Handy.formatSize(model.size)
        label1.font.pointSize: Maui.Style.fontSizes.big
        label1.font.weight: Font.Bold
    }

    listDelegate: Maui.ItemDelegate
    {
        id: _listDelegate

        property alias checked :_listTemplate.checked
        isCurrentItem: ListView.isCurrentItem || checked

        height: Maui.Style.rowHeight *1.5
        width: ListView.view.width
        leftPadding: Maui.Style.space.small
        rightPadding: Maui.Style.space.small
        draggable: true
        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ?
                           {
                               "text/uri-list": control.filterSelectedItems(model.path)
                           } : {}

    Maui.ListItemTemplate
    {
        id: _listTemplate
        leftMargin: Maui.Style.space.medium
        anchors.fill: parent
        label1.text: model.label
        label3.text: Maui.Handy.formatDate(model.modified, "MM/dd/yyyy")
        label4.text: model.mime
        iconSource: model.icon
        iconSizeHint: Maui.Style.iconSizes.small
        checkable: root.selectionMode
        checked: _selectionbar.contains(model.path)
        onToggled: addToSelection(control.model.get(index))
        isCurrentItem: _listDelegate.isCurrentItem
    }

    Connections
    {
        target: _selectionbar
        function onUriRemoved(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = false
        }

        function onUriAdded(uri)
        {
            if(uri === model.path)
                _listDelegate.checked = true
        }

        function onCleared()
        {
            _listDelegate.checked = false
        }
    }

    onClicked:
    {
        control.currentIndex = index
        if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
        {
            const item = control.model.get(control.currentIndex)
            addToSelection(item)

        }else if(Maui.Handy.singleClick)
        {
            editorView.openTab(control.model.get(index).path)
        }
    }

    onDoubleClicked:
    {
        control.currentIndex = index
        if(!Maui.Handy.singleClick && !selectionMode)
        {
            editorView.openTab(control.model.get(index).path)
        }
    }

    onRightClicked:
    {
        control.currentIndex = index
        menu.open()
    }

    onPressAndHold:
    {
        control.currentIndex = index
        menu.open()
    }
}

property string typingQuery

 Maui.Chip
 {
     z: control.z + 99999
     Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
     visible: _typingTimer.running
     label.text: typingQuery
     anchors.left: parent.left
     anchors.bottom: parent.bottom
     showCloseButton: false
     anchors.margins: Maui.Style.space.medium
 }

 Timer
 {
     id: _typingTimer
     interval: 250
     onTriggered:
     {
         const index = _documentsList.indexOfName(typingQuery)
         if(index > -1)
         {
             control.currentIndex = index
         }

         typingQuery = ""
     }
 }

 Connections
 {
     target: control.currentView

     function onKeyPress(event)
     {
         const index = control.currentIndex
         const item = control.model.get(index)

         var pat = /^([a-zA-Z0-9 _-]+)$/
         if(event.count === 1 && pat.test(event.text))
         {
             typingQuery += event.text
             _typingTimer.restart()
         }
     }
 }

}
