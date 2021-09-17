import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.2 as Maui
import org.mauikit.filebrowsing 1.3 as FB

Maui.AbstractSideBar
{
    preferredWidth: Kirigami.Units.gridUnit * 16
    collapsed: !isWide
    collapsible: true
    dragMargin: Maui.Style.space.big

    property alias browser : browserView

    onVisibleChanged:
    {
        if(currentEditor)
            syncSidebar(currentEditor.fileUrl)
    }

    Maui.Page
    {
        anchors.fill: parent
        headBar.visible: true
        headBar.background: null
        background: null

        clip: true

        headBar.middleContent: Maui.ToolActions
        {
            id: _browserViews
            currentIndex: _swipeView.currentIndex
            autoExclusive: true
            expanded: true

            Action
            {
                text: "Project"
                icon.name: "project-development"

            }

            Action
            {
                text: "Browser"
                icon.name: "folder"
            }
        }

        SwipeView
        {
            id: _swipeView
            currentIndex: _browserViews.currentIndex
            anchors.fill: parent

            Maui.Page
            {
                headBar.visible: false
                headBar.background: null
                background: null

                title: _cmakeProject.target.name

                Maui.ListBrowser
                {
                    anchors.fill: parent
                    model: Maui.BaseModel
                    {
                        list: _cmakeProject.target.sources
                        sort: "source"
                        sortOrder: Qt.AscendingOrder
                        recursiveFilteringEnabled: true
                        sortCaseSensitivity: Qt.CaseInsensitive
                        filterCaseSensitivity: Qt.CaseInsensitive
                    }

                    holder.visible: count === 0
                    holder.title: i18n("Project Sources")
                    holder.body: i18n("Source files will be listed in here.")

                    flickable.section.criteria: ViewSection.FullString
                    flickable.section.property: "place"
                    flickable.section.delegate: Maui.LabelDelegate
                    {
                        width: ListView.view.width
                        height: Maui.Style.rowHeight
                        label: section
                        isSection: true
                    }

                    delegate: Maui.ListBrowserDelegate
                    {
                        width: ListView.view.width
                        label1.text: model.label
                        iconSource: model.icon
                        iconSizeHint: Maui.Style.iconSizes.small
                        tooltipText: model.source

                        onClicked:
                        {
                            editorView.openTab(model.url)
                        }
                    }
                }
            }


            Maui.Page
            {
                headBar.background: null
                footBar.background: null
                background: null
                headBar.visible: false

                footBar.leftContent: Maui.ToolActions
                {
                    expanded: true
                    autoExclusive: false
                    checkable: false

                    Action
                    {
                        text: i18n("Previous")
                        icon.name: "go-previous"
                        onTriggered : browserView.goBack()
                    }

                    Action
                    {
                        text: i18n("Up")
                        icon.name: "go-up"
                        onTriggered : browserView.goUp()
                    }


                    Action
                    {
                        text: i18n("Next")
                        icon.name: "go-next"
                        onTriggered: browserView.goNext()
                    }
                }

                footBar.rightContent: [

                    ToolButton
                    {
                        icon.name: "edit-find"
                        checked: browserView.headBar.visible
                        onClicked:
                        {
                            browserView.headBar.visible = !browserView.headBar.visible
                        }
                    },

                    Maui.ToolButtonMenu
                    {
                        icon.name: "view-sort"

                        MenuItem
                        {
                            text: i18n("Show Folders First")
                            checked: browserView.settings.foldersFirst
                            checkable: true
                            onTriggered: browserView.settings.foldersFirst = !browserView.settings.foldersFirst
                        }

                        MenuSeparator {}

                        MenuItem
                        {
                            text: i18n("Type")
                            checked: browserView.settings.sortBy === FB.FMList.MIME
                            checkable: true
                            onTriggered: browserView.settings.sortBy = FB.FMList.MIME
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Date")
                            checked:browserView.settings.sortBy === FB.FMList.DATE
                            checkable: true
                            onTriggered: browserView.settings.sortBy = FB.FMList.DATE
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Modified")
                            checkable: true
                            checked: browserView.settings.sortBy === FB.FMList.MODIFIED
                            onTriggered: browserView.settings.sortBy = FB.FMList.MODIFIED
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Size")
                            checkable: true
                            checked: browserView.settings.sortBy === FB.FMList.SIZE
                            onTriggered: browserView.settings.sortBy = FB.FMList.SIZE
                            autoExclusive: true
                        }

                        MenuItem
                        {
                            text: i18n("Name")
                            checkable: true
                            checked: browserView.settings.sortBy === FB.FMList.LABEL
                            onTriggered: browserView.settings.sortBy = FB.FMList.LABEL
                            autoExclusive: true
                        }

                        MenuSeparator{}

                        MenuItem
                        {
                            id: groupAction
                            text: i18n("Group")
                            checkable: true
                            checked: browserView.settings.group
                            onTriggered:
                            {
                                browserView.settings.group = !browserView.settings.group
                            }
                        }
                    }
                ]

                FB.FileBrowser
                {
                    id: browserView
                    anchors.fill: parent
                    currentPath: FB.FM.homePath()
                    settings.viewType : FB.FMList.LIST_VIEW
                    settings.filterType: FB.FMList.TEXT
                    headBar.visible: false
                    floatingFooter: false
                    browser.background: null
                    background: Rectangle
                    {
                        color: Kirigami.Theme.backgroundColor
                        opacity: 0.5
                    }
                    onItemClicked:
                    {
                        var item = currentFMModel.get(index)
                        if(Maui.Handy.singleClick)
                        {
                            if(item.isdir == "true")
                            {
                                openFolder(item.path)
                            }else
                            {
                                editorView.openTab(item.path)
                            }
                        }
                    }

                    onItemDoubleClicked:
                    {
                        var item = currentFMModel.get(index)
                        if(!Maui.Handy.singleClick)
                        {
                            if(item.isdir == "true")
                            {
                                openFolder(item.path)
                            }else
                            {
                                editorView.openTab(item.path)
                            }
                        }
                    }
                }

            }
        }

    }
}
