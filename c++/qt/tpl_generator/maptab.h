#ifndef MAPTAB_H
#define MAPTAB_H

#include <QMap>
#include <QWidget>

namespace Ui {
class MapTab;
}


class MapTab : public QWidget
{
    Q_OBJECT

public:
    explicit MapTab(QWidget *parent = nullptr);
    ~MapTab();

    bool loadConfigJson(const QString &jsonFile);
    void showWith(const QMap<int, QString> &datas);
private:
    Ui::MapTab *ui;
    QMap<int, QString> m_map;

private slots:
    void onCellDoubleClicked(int row, int column);
};

#endif // MAPTAB_H
