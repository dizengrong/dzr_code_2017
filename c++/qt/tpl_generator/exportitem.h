#ifndef EXPORTITEM_H
#define EXPORTITEM_H

#include <QString>
#include <QMap>
#include <QJsonObject>



class ExportItem
{
public:
    ExportItem(const QJsonObject& json);
    bool isMatched(const QString& text);

public:
    QString m_excel_file;
    //QMap<Sheet, QMap>
    QMap<QString, QMap<QString, QString>*> m_sheets;
};

#endif // EXPORTITEM_H
