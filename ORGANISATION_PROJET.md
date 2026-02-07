# 📁 ORGANISATION DU PROJET GLSimpleSQL

## Structure du Dossier

```
GLSimpleSQL/
├── src/                          # Code source
│   ├── main.c
│   ├── sql_lexer.l
│   ├── sql_parser.y
│   ├── symbol_table.c
│   └── symbol_table.h
│
├── tests/                        # Tests SQL
│   ├── test.sql
│   ├── test_examples.sql
│   └── test_errors.sql
│
├── docs/                         # Documentation
│   └── cahier_des_charges.pdf
│
├── Makefile                      # Compilation
├── README.md                     # Documentation principale
├── GRAMMAIRE_BNF.md             # Grammaire formelle
├── Rapport_Final_GLSimpleSQL.md # Rapport détaillé
├── GRAMMAIRE_BNF.pdf            # PDF de la grammaire
└── Rapport_Final_GLSimpleSQL.pdf # PDF du rapport
```

---

## 📋 FICHIERS À SOUMETTRE (GITHUB)

Le dépôt GitHub contient les fichiers essentiels :
- ✅ `src/` (sources)
- ✅ `tests/` (fichiers SQL)
- ✅ `docs/` (cahier des charges)
- ✅ `Makefile`
- ✅ `README.md`
- ✅ `GRAMMAIRE_BNF.md` & `.pdf`
- ✅ `Rapport_Final_GLSimpleSQL.md` & `.pdf`
- ✅ `.gitignore`

---

## 🗂️ FICHIERS LOCAUX (NON-GIT)

Certains fichiers sont conservés localement mais exclus de GitHub :
- `build/` & `bin/` (fichiers compilés)
- `documentation_reference/` (guides détaillés)
- Scripts de préparation (`*.sh`)
- Journaux et fichiers temporaires (`*.txt`, `*.log`)
