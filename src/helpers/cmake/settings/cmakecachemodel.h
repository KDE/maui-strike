/* KDevelop CMake Support
 *
 * Copyright 2007-2008 Aleix Pol <aleixpol@gmail.com>
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

#ifndef CMAKECACHEMODEL_H
#define CMAKECACHEMODEL_H

#include <cmakecommonexport.h>
#include <QStandardItemModel>
#include <QVariant>
#include <QSet>

#include <util/path.h>

/**
* This class parses the CMakeCache.txt files and put it to a Model
* @author Aleix Pol
*/
class CMakeCacheModel : public QStandardItemModel
{
    Q_OBJECT
    public:
        CMakeCacheModel(QObject* parent, const KDevelop::Path &path);
        ~CMakeCacheModel() override {}

        bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

        int internal() const { return m_internalBegin; }
        
        QString value(const QString& name) const;
        bool isAdvanced(int i) const;
        bool isInternal(int i) const;
        
        QList<QModelIndex> persistentIndices() const;
        KDevelop::Path filePath() const;
        void read();
        QVariantMap changedValues() const;

    Q_SIGNALS:
        void valueChanged(const QString& name, const QString& value) const;

    public Q_SLOTS:
        void reset();
        
    private:
        KDevelop::Path m_filePath;
        int m_internalBegin;
        QSet<QString> m_internal;
        QSet<int> m_modifiedRows;
};

#endif
