#ifndef LANGTAB_H
#define LANGTAB_H

#include <QWidget>

namespace Ui {
class LangTab;
}

class LangTab : public QWidget
{
    Q_OBJECT

public:
    explicit LangTab(QWidget *parent = 0);
    ~LangTab();

    void loadConfigJson(const QString &jsonFile);

private:
    Ui::LangTab *ui;

private slots:
    void onCellDoubleClicked(int row, int column);
};

#endif // LANGTAB_H
