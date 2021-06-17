/* KDevelop CMake Support
 *
 * Copyright 2013 Aleix Pol <aleixpol@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#ifndef KDEVPROJECTOPEN_H
#define KDEVPROJECTOPEN_H

#include <QObject>
#include <QUrl>

namespace KDevelop { class IProject; }

class KDevProjectOpen : public QObject
{
    Q_OBJECT

public:
    explicit KDevProjectOpen(QObject* parent = nullptr);
    void openProject(const QUrl& path);
    void cleanup();
private Q_SLOTS:
    void projectDone(KDevelop::IProject*);

private:
    int m_toOpen = 0;
};

#endif
