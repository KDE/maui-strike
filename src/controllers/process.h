#pragma once

#include <QObject>

class Process : public QObject
{
  Q_OBJECT
public:
  explicit Process(QObject *parent = nullptr);

};
