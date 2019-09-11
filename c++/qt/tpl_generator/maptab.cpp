#include "maptab.h"
#include "ui_maptab.h"

#include <QFile>
#include <QJsonObject>
#include <QJsonParseError>
#include <QMessageBox>
#include <QDebug>
#include <QJsonArray>

MapTab::MapTab(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::MapTab)
{
    ui->setupUi(this);

    QStringList header;
    header.append("ID");
    header.append("obj掩码文件名");
    header.append("erl地图配置(双击导出)");
    header.append("c地图配置(双击导出)");
    ui->m_table->setColumnCount(header.size());

    ui->m_table->setHorizontalHeaderLabels(header);
    ui->m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    ui->m_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_table->setSortingEnabled(false);
    connect(ui->m_table, &QTableWidget::cellDoubleClicked, this, &MapTab::onCellDoubleClicked);
}

MapTab::~MapTab()
{
    delete ui;
}

bool MapTab::loadConfigJson(const QString &jsonFile)
{
    QFile loadFile(jsonFile);

    if(!loadFile.open(QIODevice::ReadOnly))
    {
        QMessageBox::critical(this,"error","cannot find file:" + jsonFile);
        return false;
    }

    QByteArray allData = loadFile.readAll();
    loadFile.close();

    QJsonParseError json_error;
    QJsonDocument jsonDoc(QJsonDocument::fromJson(allData, &json_error));

    if(json_error.error != QJsonParseError::NoError)
    {
        QMessageBox::critical(this,"error","parse json error:" + json_error.errorString());
        return false;
    }

    QJsonObject rootObj = jsonDoc.object();
    auto it = rootObj.begin();
    while (it != rootObj.end()) {
        m_map.insert(it.value().toInt(), it.key().toLower());
        ++it;
    }

    showWith(m_map);
    return true;
}

void MapTab::showWith(const QMap<int, QString> &datas)
{
    ui->m_table->setRowCount(datas.size() + 1);

    auto it = datas.begin();
    int count = 0;
    while (it != datas.end()) {
        ui->m_table->setItem(count, 0, new QTableWidgetItem(it.key()));
        ui->m_table->setItem(count, 1, new QTableWidgetItem(it.value()));
        ui->m_table->setItem(count, 2, new QTableWidgetItem("data_map_" + QString(it.key()) + ".erl"));
        ui->m_table->setItem(count, 3, new QTableWidgetItem("data_map_" + QString(it.key()) + ".c"));
        ++it;
        ++count;
    }
}

void MapTab::onCellDoubleClicked(int row, int column)
{

}
