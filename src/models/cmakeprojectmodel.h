#ifndef CMAKEPROJECTMODEL_H
#define CMAKEPROJECTMODEL_H

#include <QObject>

class CMakeProjectModel : public QObject
{
    Q_OBJECT
public:
    explicit CMakeProjectModel(QObject *parent = nullptr);

signals:

};

#endif // CMAKEPROJECTMODEL_H
