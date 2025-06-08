# Test technique Indy

Application Rails permettant la gestion de codes promo via une API REST.

## 🛠 Prérequis

- Ruby 3.4.1
- Rails 8.0.2
- PostgreSQL

## 🚀 Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/inicolas69/promocode_validator.git
   cd promocode_validator
   ```
2. **Installer les dépendances**
   ```bash
   bundle install
   ```
3. **Créer et préparer la base de données**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

## ▶️ Lancement du serveur

```bash
rails server
```

L’application sera disponible sur [http://localhost:3000](http://localhost:3000).

## 💻 Disponible en ligne

L'application est aussi disponible en ligne [ici](https://promocode-validator-558dea08f98a.herokuapp.com)

## 📖 API

### 1. Créer un code promo

- **Route** : `POST /api/v1/promo_codes`
- **Payload attendu** :

  ```json
  {
    "name": "WeatherCode",
    "advantage": { "percent": 20 },
    "restrictions": [
      {
        "date": {
          "after": "2025-01-01",
          "before": "2025-12-31"
        }
      },
      {
        "or": [
          {
            "age": {
              "eq": 40
            }
          },
          {
            "and": [
              {
                "age": {
                  "lt": 30,
                  "gt": 15
                }
              },
              {
                "weather": {
                  "is": "clear",
                  "temp": {
                    "gt": 15
                  }
                }
              }
            ]
          }
        ]
      }
    ]
  }
  ```

#### Exemple avec curl

```bash
curl --request POST \
  --url https://promocode-validator-558dea08f98a.herokuapp.com/api/v1/promo_codes \
  --header 'Content-Type: application/json' \
  --data '{
  "name": "WeatherCode",
  "advantage": { "percent": 20 },
  "restrictions": [
    {
      "date": {
        "after": "2019-01-01",
        "before": "2020-06-30"
      }
    },
    {
      "or": [
        {
          "age": {
            "eq": 40
          }
        },
        {
          "and": [
            {
              "age": {
                "lt": 30,
                "gt": 15
              }
            },
            {
              "weather": {
                "is": "clear",
                "temp": {
                  "gt": 15 // Celsius here.
                }
              }
            }
          ]
        }
      ]
    }
  ]
}'
```

### 2. Valider un code promo

- **Route** : `POST /api/v1/promo_codes/validate`
- **Payload attendu** :

  ```json
  {
    "promocode_name": "ELDERLY_RAIN",
    "arguments": {
      "age": 26,
      "town": "Lyon"
    }
  }
  ```

#### Exemple avec curl

```bash
curl --request POST \
  --url https://promocode-validator-558dea08f98a.herokuapp.com/api/v1/promo_codes/validate \
  --header 'Content-Type: application/json' \
  --data '{
  "promocode_name": "ELDERLY_RAIN",
  "arguments": {
    "age": 26,
    "town": "Lyon"
  }
}'
```

### Utiliser Postman

[<img src="https://run.pstmn.io/button.svg" alt="Run In Postman" style="width: 128px; height: 32px;">](https://app.getpostman.com/run-collection/11049148-04d6b926-594c-4e9f-9053-1315074633e5?action=collection%2Ffork&source=rip_markdown&collection-url=entityId%3D11049148-04d6b926-594c-4e9f-9053-1315074633e5%26entityType%3Dcollection%26workspaceId%3D0d0c9731-7420-4d20-93fd-42ffff643f75)

(Petit test, je n'avais jamais tenté ça)

## 🧪 Lancer les tests

Des tests sont disponibles via RSpec. Pour les exécuter :

```bash
rspec
```

## 📎 Notes complémentaires

### Infrastructure du code

- J'ai décidé d'utiliser 3 modèles **PromoCode**, **RestrictionGroup** et **Restriction** pour représenter la donnée.
- Chaque **PromoCode** a un ou plusieurs **RestrictionGroup** qui peuvent contenir des **Restriction** ou d'autres **RestrictionGroup**.
- La classe **Restriction** est une classe STI, ayant plusieurs sous-classes **Restriction::Age**, **Restriction::Date** et **Restriction::Weather** permettant de gérer indépendamment les logiques de validation de coupon.
- J'ai extrait dans le service **PromoCodeBuilder** toute la logique permettant de créer en DB les données provenants du call API.
- Le service **PromoCodeValidator** quant à lui contient la logique de validation ou non d'un coupon selon le contexte.

### Pistes d'améliorations

- Améliorer la réponse du call API de création de coupon pour matcher parfaitement la donnée d'entrée, car actuellement j'ajoute une couche de **RestrictionGroup** à la racine. On pourrait aussi modifier le format de donnée d'entrée.
- Améliorer la gestion des erreurs.
- Ajouter des tests que j'ai potentiellement oubliés.
