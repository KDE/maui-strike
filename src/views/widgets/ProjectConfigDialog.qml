import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.slike.strike 1.0 as Strike

Maui.Dialog
{
    id: control

    title: i18n("Configure")
    headBar.visible: false
    page.floatingHeader: true
    closeButtonVisible: false
    persistent: true
    defaultButtons: true
    rejectButton.text: _stackView.depth > 1 ? i18n("Go back") : i18n ("Abort")
    acceptButton.text: stepLabel(_stackView.depth)

    onAccepted:
    {
        switch(_stackView.depth)
        {
        case 1: _project.configure()
            _stackView.push(_step2Component)
            break
        case 2: control.close()
            break
        }
    }

    onRejected:
    {
        switch(_stackView.depth)
        {
        case 1: control.close
            break
        case 2: _stackView.pop()
            break
        }
    }

    stack: StackView
    {
        id: _stackView
        Layout.fillHeight: true
        Layout.fillWidth: true

        initialItem: Item
        {
            ColumnLayout
            {
                anchors.centerIn: parent
                width: parent.width
                spacing: Maui.Style.space.medium

                Maui.Holder
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    Layout.alignment: Qt.AlignCenter
                    title: i18n("Configure")
                    body: i18n("Set the preferences to start hacking!")
                    emoji: "alienarena"
                    isMask: false
                    emojiSize: 64
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    Maui.ListItemTemplate
                    {
                        width: parent.width
                        anchors.centerIn: parent
                        label1.text: i18n("Build Directory")
                        label2.text: i18n("Pick a build directory or keep the default one")
                        leftLabels.data: Maui.TextField
                        {
                            Layout.fillWidth: true
                            placeholderText: i18n("Build directory path")
                            text: _project.preferences.buildDir
                        }
                    }
                }

                //                Maui.ListItemTemplate
                //                {
                //                    Layout.fillWidth: true
                //                    label1.text: i18n("Install Prefix")
                //                    label2.text: i18n("Where do you want to install the project")
                //                    leftLabels.data: Maui.TextField
                //                    {
                //                        Layout.fillWidth: true
                //                        placeholderText: i18n("Prefix path")
                //                        text: _project.preferences.installPrefix
                //                    }
                //                }
            }
        }

        Component
        {
            id: _step2Component

            Item
            {
                ColumnLayout
                {
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: Maui.Style.space.medium

                    Maui.Holder
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        Layout.alignment: Qt.AlignCenter
                        isMask: false
                        title: i18n("Project")
                        body: i18n("Select the target project")
                        emoji: _project.projectLogo
                        emojiSize: 64
                    }

                    Item
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120

                        Maui.ListBrowser
                        {
                            id: _projectsListView
                            height: 100
                            width: parent.width
                            anchors.centerIn: parent
                            model: _project.manager.projectsModel
                            spacing: Maui.Style.space.medium
                            delegate: Maui.GridBrowserDelegate
                            {
                                isCurrentItem: ListView.isCurrentItem
                                checked: isCurrentItem
                                anchors.verticalCenter: parent.verticalCenter
                                width: 64
                                height: 80
                                label1.text: model.title
                                iconSource: "run-build"

                                onClicked:
                                {
                                    _projectsListView.currentIndex = index
                                    _cmakeProject.setData(model.data)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function stepLabel(index)
    {
        switch(index)
        {
        case 1: return i18n("Configure")
        case 2: return i18n("Continue")
        case 3: return i18n("Finish")
        }
    }
}
