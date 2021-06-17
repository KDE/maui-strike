/* KDevelop CMake Support
 *
 * Copyright 2013 Aleix Pol Gonzalez <aleixpol@kde.org>
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

#ifndef PRUNEJOB_H
#define PRUNEJOB_H
#include <outputview/outputjob.h>

namespace KDevelop { class IProject; }

class PruneJob : public KDevelop::OutputJob
{
    Q_OBJECT
    public:
        explicit PruneJob(KDevelop::IProject* project);
        void start() override;
        bool doKill() override;

    private Q_SLOTS:
        void jobFinished(KJob* job);

    private:
        KDevelop::IProject* m_project;
        KJob* m_job;
};

#endif // PRUNEJOB_H
