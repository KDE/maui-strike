/*  This file is part of KDevelop
    Copyright 2012 Miha Čančula <miha@noughmad.eu>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; see the file COPYING.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "ctestfindjob.h"
#include "ctestsuite.h"
#include <debug.h>

#include <interfaces/icore.h>
#include <interfaces/ilanguagecontroller.h>
#include <language/duchain/duchain.h>
#include <language/backgroundparser/backgroundparser.h>

#include <kcoreaddons_version.h>
#include <KLocalizedString>

CTestFindJob::CTestFindJob(CTestSuite* suite, QObject* parent)
: KJob(parent)
, m_suite(suite)
{
    qCDebug(CMAKE) << "Created a CTestFindJob";
    setObjectName(i18n("Parse test suite %1", suite->name()));
    setCapabilities(Killable);
}

void CTestFindJob::start()
{
    qCDebug(CMAKE) << "Finding test cases";
    QMetaObject::invokeMethod(this, &CTestFindJob::findTestCases, Qt::QueuedConnection);
}

void CTestFindJob::findTestCases()
{
    m_pendingFiles.clear();
    const auto& sourceFiles = m_suite->sourceFiles();
    for (const auto& file : sourceFiles) {
        if (!file.isEmpty())
        {
            m_pendingFiles << file;
        }
    }
    qCDebug(CMAKE) << "Source files to update:" << m_pendingFiles;

    if (m_pendingFiles.isEmpty()) {
        emitResult();
        return;
    }

    const auto currentPendingFiles = m_pendingFiles;
    for (const KDevelop::Path& file : currentPendingFiles) {
        KDevelop::DUChain::self()->updateContextForUrl(KDevelop::IndexedString(file.toUrl()), KDevelop::TopDUContext::AllDeclarationsAndContexts, this);
    }
}

void CTestFindJob::updateReady(const KDevelop::IndexedString& document, const KDevelop::ReferencedTopDUContext& context)
{
#if KCOREADDONS_VERSION >= QT_VERSION_CHECK(5, 75, 0)
    if (Q_UNLIKELY(isFinished())) {
#else
    if (Q_UNLIKELY(error() == KilledJobError)) {
#endif
        qCDebug(CMAKE) << "Cannot add test suite" << m_suite->name() << ": this job has been killed.";
        return;
    }

    if (Q_UNLIKELY(!m_suite->project())) {
        qCDebug(CMAKE) << "Cannot add test suite" << m_suite->name()
                       << "because its project is already destroyed (probably closed by the user).";
        kill();
        return;
    }

    qCDebug(CMAKE) << "context update ready" << m_pendingFiles << document.str();
    m_suite->loadDeclarations(document, context);
    m_pendingFiles.removeAll(KDevelop::Path(document.toUrl()));

    if (m_pendingFiles.isEmpty()) {
        emitResult();
    }
}

bool CTestFindJob::doKill()
{
    KDevelop::ICore::self()->languageController()->backgroundParser()->revertAllRequests(this);
    return true;
}
