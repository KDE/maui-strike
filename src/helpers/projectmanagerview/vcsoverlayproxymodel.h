/* This file is part of KDevelop
    Copyright 2008 Aleix Pol <aleixpol@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#ifndef KDEVPLATFORM_PLUGIN_VCSOVERLAYPROXYMODEL_H
#define KDEVPLATFORM_PLUGIN_VCSOVERLAYPROXYMODEL_H

#include <project/projectmodel.h>
#include <QIdentityProxyModel>

class QUrl;
namespace KDevelop {
    class IProject;
    class VcsJob;
}

class VcsOverlayProxyModel : public QIdentityProxyModel
{
    Q_OBJECT
    public:
        enum Roles {
            VcsStatusRole = KDevelop::ProjectModel::LastRole
        };
        explicit VcsOverlayProxyModel(QObject* parent = nullptr);

        QVariant data(const QModelIndex& proxyIndex, int role = Qt::DisplayRole) const override;

    private Q_SLOTS:
        void addProject(KDevelop::IProject* p);
        void removeProject(KDevelop::IProject* p);
        void repositoryBranchChanged(const QUrl& url);
        void branchNameReady(KDevelop::VcsJob* job);

    private:
        QModelIndex indexFromProject(QObject* project);
        QHash<KDevelop::IProject*, QString> m_branchName;
};

#endif // KDEVPLATFORM_PLUGIN_VCSOVERLAYPROXYMODEL_H
