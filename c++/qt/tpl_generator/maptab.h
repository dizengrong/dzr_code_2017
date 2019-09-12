#ifndef MAPTAB_H
#define MAPTAB_H

#include <QMap>
#include <QWidget>

namespace Ui {
class MapTab;
}

class MainWindow;

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
    MainWindow* m_mainWindow;

private slots:
    void onCellDoubleClicked(int row, int column);
    void on_m_btn_erlmap_dir_clicked();
    void on_m_btn_cmap_dir_clicked();
};

#endif // MAPTAB_H
