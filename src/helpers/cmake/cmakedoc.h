/* KDevelop CMake Support
 *
 * Copyright 2009 Aleix Pol <aleixpol@kde.org>
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

#ifndef CMAKEDOC_H
#define CMAKEDOC_H

#include <interfaces/idocumentation.h>
class CMakeDocumentation;

class CMakeDoc : public KDevelop::IDocumentation
{
    Q_OBJECT

    public:
        CMakeDoc(const QString& name, const QString& desc) : mName(name), mDesc(desc) {}
        
        QString description() const override { return mDesc; }
        QString name() const override { return mName; }
        KDevelop::IDocumentationProvider* provider() const override;
        
        QWidget* documentationWidget(KDevelop::DocumentationFindWidget* findWidget, QWidget* parent = nullptr) override;
        
        static CMakeDocumentation* s_provider;
        
    private:
        QString mName, mDesc;
};

#endif
