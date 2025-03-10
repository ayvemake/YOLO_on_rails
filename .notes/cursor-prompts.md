# Prompts optimisés pour Cursor.dev (multi-dossiers)

## Prompts généraux

```
Utilise les fichiers project-overview.md, backend-overview.md et cross-integration.md
pour comprendre l'architecture de l'application. Utilise la structure décrite dans 
directory-structure.md pour naviguer entre les dossiers Rails et Python.
```

## Prompts pour travailler sur les deux dossiers à la fois

```
Aide-moi à implémenter la fonctionnalité [DESCRIPTION]. Cela implique de modifier:
1. Côté Rails: [FICHIERS_RAILS]
2. Côté Python: [FICHIERS_PYTHON]

Assure-toi que les changements sont cohérents avec le format d'échange défini dans 
cross-integration.md.
```

## Prompts pour l'implémentation de l'endpoint /analyze

```
Implémente l'endpoint /analyze dans le backend Python et le service correspondant côté 
Rails. L'endpoint doit suivre la spécification dans cross-integration.md, en utilisant
YOLOv8 puis U-Net comme décrit dans backend-overview.md.
```

## Prompts pour débogage cross-platform

```
J'ai un problème d'intégration entre Rails et Python: [DESCRIPTION_PROBLÈME].
La requête Rails est [REQUÊTE] et la réponse Python est [RÉPONSE].
Aide-moi à diagnostiquer et corriger ce problème en tenant compte des deux côtés.
```

## Prompts pour ajouter une nouvelle fonctionnalité

```
Je souhaite ajouter une nouvelle fonctionnalité permettant [DESCRIPTION].
Cela nécessite:
1. Un nouvel endpoint dans l'API Python
2. Un nouveau service dans Rails
3. Une interface utilisateur pour exploiter cette fonctionnalité

Guide-moi à travers ces modifications en tenant compte des conventions et
de la structure existante des deux projets.
```
