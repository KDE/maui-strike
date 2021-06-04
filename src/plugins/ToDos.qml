import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: plugin
footBar.visible: true
    ListModel
    {
        id: todos
    }

    Layout.fillWidth: true
    Layout.maximumHeight: 500
    Layout.preferredHeight: _listView.contentHeight + 200

    ListView
    {
        id: _listView
        anchors.fill: parent
        model: todos
        delegate: CheckBox
        {
            width: ListView.view.width
            checkable: true
            checked: false
            text: model.label
            font.strikeout: checked
//            onToggled: todos.remove(index)
        }
    }

    footBar.middleContent : Maui.TextField
    {
        placeholderText: i18n("New ToDo... Argh!")
        Layout.fillWidth: true
        onAccepted:
        {
             todos.append({'label': text})
            clear()
        }

    }
}
