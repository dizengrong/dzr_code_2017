#ifndef LANGTAB_H
#define LANGTAB_H

#include <QWidget>

namespace Ui {
class LangTab;
}

class MainWindow;

class LangTab : public QWidget
{
    Q_OBJECT

public:
    explicit LangTab(MainWindow *parent = nullptr);
    ~LangTab();

    void loadConfigJson(const QString &jsonFile);
    void initExportTable(const QJsonObject &jsonObj);
    void initSourceTable(const QJsonObject &jsonObj);

private:
    Ui::LangTab *ui;
    MainWindow* m_mainWindow;

private slots:
    void onCellDoubleClicked(int row, int column);
};

#endif // LANGTAB_H
