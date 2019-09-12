#include "langtab.h"
#include "ui_langtab.h"

#include <QJsonObject>
#include <QJsonParseError>
#include <QDebug>
#include <QJsonArray>

LangTab::LangTab(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LangTab)
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
    qDebug() << json_error.errorString();
    if(json_error.error != QJsonParseError::NoError)
    {
        return;
    }

    QJsonObject rootObj = jsonDoc.object();
    QJsonObject exportFiles = rootObj.value("lang_export_files").toObject();
    qDebug() << exportFiles.size();
    ui->m_export_table->setRowCount(exportFiles.size() + 1);
    qDebug() << "aaaa";
    auto it = exportFiles.begin();
    int count = 0;
    QString id;
    QJsonArray arr;
    while (it != exportFiles.end()) {
        id = QString::number(count + 1);
        ui->m_export_table->setItem(count, 0, new QTableWidgetItem(id));
        ui->m_export_table->setItem(count, 1, new QTableWidgetItem(it.key()));
        arr = it.value().toArray();
        ui->m_export_table->setItem(count, 1, new QTableWidgetItem(arr.at(0).toString()));
        ++it;
    }
}

void LangTab::onCellDoubleClicked(int row, int column)
{

}
