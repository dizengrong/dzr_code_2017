#include "exportitem.h"

#include <QFileInfo>
#include <QJsonArray>

ExportItem::ExportItem(const QJsonObject& json)
{
    m_excel_file = json.value("excle_file").toString();
    QJsonArray exports = json.value("export").toArray();
    QMap<QString, QString> *map;
    QJsonObject data, data2, tpl_dict;

    QString sheet;
    QMap<QString, QMap<QString, QString>*>::iterator it;
    int size = exports.size();
    for (int j = 0; j < size; ++j){
        data = exports.at(j).toObject();
        QString tpl = data.value("tpl").toString();
        QString file_type = QFileInfo(QFileInfo(tpl).completeSuffix()).baseName();
        QString tpl_file = QFileInfo(tpl).baseName() + "." + file_type;
        QJsonArray dicts = data.value("dict").toArray();
        for (int i = 0; i < dicts.size(); ++i) {
            data2 = dicts.at(i).toObject();
            sheet = data2.value("sheet").toString();
            it = m_sheets.find(sheet);
            if (it != m_sheets.end()) {
                map = it.value();
            }
            else {
                map = new QMap<QString, QString>;
                map->insert("sheet", sheet);
            }
            map->insert("export_" + file_type, tpl_file);
            m_sheets.insert(sheet, map);
        }


    }
}
