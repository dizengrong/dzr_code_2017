#include "langtab.h"
#include "mainwindow.h"
#include "setting.h"
#include "ui_langtab.h"

#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>
#include <QJsonArray>
#include <algorithm>

LangTab::LangTab(MainWindow *parent) :
    QWidget(parent),
    ui(new Ui::LangTab),
    m_mainWindow(parent)
{
    ui->setupUi(this);

    QStringList header;
    header.append("ID");
    header.append(tr("lang_header_excel"));
    header.append(tr("lang_header_tr"));
    ui->m_export_table->setColumnCount(header.size());

    ui->m_export_table->setHorizontalHeaderLabels(header);
    ui->m_export_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    ui->m_export_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_export_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_export_table->setSortingEnabled(false);
    qDebug() << ui->m_export_table;
    connect(ui->m_export_table, &QTableWidget::cellDoubleClicked, this, &LangTab::onCellDoubleClicked);
}

LangTab::~LangTab()
{
    delete ui;
}

void LangTab::loadConfigJson(const QString &jsonData)
{
    qDebug() << jsonData;
    QJsonParseError json_error;
    QJsonDocument jsonDoc(QJsonDocument::fromJson(jsonData.toLocal8Bit(), &json_error));

    if(json_error.error != QJsonParseError::NoError)
    {
        qDebug() << "load lang config error:" << json_error.errorString();
        return;
    }

    QJsonObject rootObj = jsonDoc.object();
    QJsonObject exportFiles = rootObj.value("lang_export_files").toObject();

    initExportTable(exportFiles);
    initSourceTable(rootObj.value("lang_src_dict").toObject());

}

void LangTab::initExportTable(const QJsonObject &jsonObj)
{
    ui->m_export_table->setRowCount(jsonObj.size() + 1);
    auto it = jsonObj.begin();
    int count = 0;
    QString id;
    QJsonArray arr;
    while (it != jsonObj.end()) {
        id = QString::number(count + 1);
        ui->m_export_table->setItem(count, 0, new QTableWidgetItem(id));
        ui->m_export_table->setItem(count, 1, new QTableWidgetItem(it.key()));
        arr = it.value().toArray();
        ui->m_export_table->setItem(count, 2, new QTableWidgetItem(arr.at(0).toString()));

        ui->m_export_table->item(count, 0)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ui->m_export_table->item(count, 1)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ui->m_export_table->item(count, 2)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);

        ++it;
        ++count;
    }
}

void LangTab::initSourceTable(const QJsonObject &jsonObj)
{
    int max_zh_clos = 0;
    auto it = jsonObj.begin();
    QJsonArray arr;
    while (it != jsonObj.end()) {
        arr = it.value().toArray();
        for (int i = 0; i < arr.size(); ++i) {
            QJsonObject obj = arr.at(i).toObject();
            QJsonArray zh_clos = obj.value("cols_with_name").toArray();
            max_zh_clos = std::max(max_zh_clos, zh_clos.size());
        }
        ++it;
    }
    QStringList header;
    header.append("ID");
    header.append("Excel文件");
    header.append("Sheet名称");
    for (int j = 0; j < max_zh_clos; ++j) {
        header.append("中文列");
    }
    ui->m_cols_table->setColumnCount(header.size());

    ui->m_cols_table->setHorizontalHeaderLabels(header);
    ui->m_cols_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    ui->m_cols_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_cols_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_cols_table->setSortingEnabled(false);

    ui->m_cols_table->setRowCount(jsonObj.size() + 1);

    it = jsonObj.begin();
    int count = 0;
    QString id;
    while (it != jsonObj.end()) {
        arr = it.value().toArray();
        for (int i = 0; i < arr.size(); ++i) {
            id = QString::number(count + 1);
            ui->m_cols_table->setItem(count, 0, new QTableWidgetItem(id));
            ui->m_cols_table->setItem(count, 1, new QTableWidgetItem(it.key()));

            QJsonObject obj = arr.at(i).toObject();
            ui->m_cols_table->setItem(count, 2, new QTableWidgetItem(obj.value("sheet").toString()));
            QJsonArray zh_clos = obj.value("cols_with_name").toArray();
            for (int j = 0; j < zh_clos.size(); ++j) {
                ui->m_cols_table->setItem(count, 3 + j, new QTableWidgetItem(zh_clos.at(j).toString()));
            }
            ++count;
        }
        ++it;
    }
}

void LangTab::onCellDoubleClicked(int row, int column)
{
    QTableWidgetItem *item = ui->m_export_table->item(row, column);
    if(column == 2){
        m_mainWindow->exportLangFile(Setting::getInstatnce().getErlDir(), item->text());
    }
}
