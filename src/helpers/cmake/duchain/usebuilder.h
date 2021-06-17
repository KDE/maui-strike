/* KDevelop CMake Support
 *
 * Copyright 2014 Aleix Pol <aleixpol@kde.org>
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

#ifndef USEBUILDER_H
#define USEBUILDER_H

#include <util/stack.h>

#include "contextbuilder.h"

class UseBuilder
{
public:
    explicit UseBuilder(const KDevelop::ReferencedTopDUContext& ctx);

    void startVisiting(CMakeContentIterator* node);

private:
    void newUse(const KDevelop::RangeInRevision& sr, const KDevelop::DeclarationPointer& d);

    KDevelop::ReferencedTopDUContext m_ctx;
};

#endif // USEBUILDER_H
