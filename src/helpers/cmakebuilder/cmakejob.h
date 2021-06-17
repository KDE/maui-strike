/* KDevelop CMake Support
 *
 * Copyright 2006-2007 Andreas Pakulat <apaku@gmx.de>
 * Copyright 2008 Hamish Rodda <rodda@kde.org>
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

#ifndef CMAKEJOB_H
#define CMAKEJOB_H

#include <outputview/outputexecutejob.h>

#include <util/path.h>

namespace KDevelop {
class IProject;
class ProjectBaseItem;
}

class CMakeJob: public KDevelop::OutputExecuteJob
{
    Q_OBJECT

public:
    enum ErrorTypes
    {
        NoProjectError = UserDefinedError,
        FailedError
    };

    explicit CMakeJob(QObject* parent = nullptr);
    
    void setProject(KDevelop::IProject* project);

    void start() override;

    // This returns the build directory for registered item.
    QUrl workingDirectory() const override;

    // This returns the "cmake" command line.
    QStringList commandLine() const override;

    // This returns the configured global environment profile.
    QString environmentProfile() const override;

private:
    QStringList cmakeArguments( KDevelop::IProject* project );
    KDevelop::Path buildDir( KDevelop::IProject* project );

    KDevelop::IProject* m_project = nullptr;
};

#endif // CMAKEJOB_H
